# Build an offline, synthetic tokenizer for Helix's Qwen3-30B-A3B runs.
#
# Why: Helix's host sends synthetic token ids (list(range(input_len))) and the prototype runs
# with dummy weights, so the tokenizer is only used by vLLM 0.4.0 to (1) read the eos id and
# (2) detokenize sampled ids. Both only need a tokenizer whose vocabulary covers every id the
# model can emit, i.e. vocab_size = 151936. This avoids downloading Qwen's tokenizer and avoids
# tokenizer-format incompatibilities with the old transformers/tokenizers that vLLM 0.4.0 uses.
#
# If you prefer the real tokenizer, copy tokenizer.json / tokenizer_config.json / vocab.json /
# merges.txt from Qwen/Qwen3-30B-A3B into ./model instead (not required for benchmarking).
#
# Usage: python make_dummy_tokenizer.py [model_dir]   (default: ./model)
import json
import os
import sys

from tokenizers import Tokenizer, models, pre_tokenizers, decoders
from transformers import PreTrainedTokenizerFast


def main():
    model_dir = sys.argv[1] if len(sys.argv) > 1 else "./model"
    with open(os.path.join(model_dir, "config.json")) as f:
        config = json.load(f)
    vocab_size = config["vocab_size"]
    bos_id, eos_id = config["bos_token_id"], config["eos_token_id"]

    vocab = {f"<t{i}>": i for i in range(vocab_size)}
    tok = Tokenizer(models.WordLevel(vocab=vocab, unk_token="<t0>"))
    tok.pre_tokenizer = pre_tokenizers.WhitespaceSplit()
    tok.decoder = decoders.WordPiece(prefix="##")  # joins tokens with spaces

    fast = PreTrainedTokenizerFast(
        tokenizer_object=tok,
        bos_token=f"<t{bos_id}>",
        eos_token=f"<t{eos_id}>",
        unk_token="<t0>",
        pad_token=f"<t{eos_id}>",
        model_max_length=config.get("max_position_embeddings", 4096),
    )
    fast.save_pretrained(model_dir)
    print(f"Saved synthetic tokenizer (vocab={vocab_size}, bos={bos_id}, eos={eos_id}) "
          f"to {model_dir}")


if __name__ == "__main__":
    main()
