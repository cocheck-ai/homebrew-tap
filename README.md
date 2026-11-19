# CoCheck Homebrew tap

Homebrew formula for [CoCheck](https://github.com/cocheck-ai/cocheck), which shows what AI agents changed in your files, step by step.

```
brew install cocheck-ai/tap/cocheck
```

Then run `cocheck install --home <folder>` once and restart your agent.

The formula installs the same tarball that is published to npm (`npm install -g cocheck`). Each release updates `Formula/cocheck.rb` with that tarball's URL and sha256.

Issues and pull requests for CoCheck itself go to [cocheck-ai/cocheck](https://github.com/cocheck-ai/cocheck).
