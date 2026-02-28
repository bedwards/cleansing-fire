# Investigation Templates

Pre-built investigation templates that combine Cleansing Fire plugins, OSINT methods, and the Claude Code CLI into ready-to-run civic investigations.

## How to Use

```bash
# Run an investigation interactively
claude -p "$(cat investigations/corporate-entity.md) Target: Palantir Technologies"

# Or use the investigate skill
claude
> /investigate Palantir Technologies
```

## Templates

| Template | Target | Plugins Used |
|----------|--------|-------------|
| `corporate-entity.md` | Any corporation | corp-sec, civic-fec, civic-spending, civic-crossref, news-monitor, lobby-tracker |
| `politician.md` | Elected officials | civic-fec, civic-legiscan, lobby-tracker, news-monitor |
| `dark-money.md` | Dark money networks | civic-fec, civic-crossref, corp-sec, osint-social |
| `government-contract.md` | Federal contracts | civic-spending, civic-crossref, corp-sec, lobby-tracker |
| `industry-capture.md` | Regulatory capture | lobby-tracker, civic-legiscan, civic-fec, news-monitor, corp-sec |

## Principles

Every investigation follows Pyrrhic Lucidity:
- **Lucidity Before Liberation**: Present all findings, including inconvenient ones
- **Differential Solidarity**: Scrutiny proportional to power held
- **Transparent Mechanism**: Show sources and methodology
- **Recursive Accountability**: Your investigation faces the same scrutiny you apply
