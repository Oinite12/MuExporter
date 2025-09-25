***<u>DISCLAIMER! THIS IS A HIGHLY WORK-IN-PROGRESS PROJECT AND IS PRETTY MUCH USELESS IN ITS CURRENT STATE.</u>***
# MuExporter
MuExporter is a Balatro mod that exports data from modded content and prepares it to be useable on the [Modded Balatro Wiki](//balatromods.miraheze.org), streamlining the process of adding initial data to the wiki before in-depth documentation begins. MuExporter is designed with modularity in mind so that the mod can be easily expanded to support atypical item types, catering to the unique quirks of each item type that would prevent an all-encompassing solution from being developed.

This mod was inspired by pre-existing data extractors such as [CardExporter](//github.com/lshtech/CardExporter) (particularly [Mysthaps's fork](//github.com/Mysthaps/CardExporter)) and [BalatroDumper](//github.com/BakersDozenBagels/BalatroDumper).

## Supported item types
- [X] Centers
  - [X] Jokers
  - [X] Decks
  - [X] Vouchers
  - [X] Consumables
  - [X] Enhancements
  - [X] Editions
  - [ ] Booster Packs
- [ ] Seals
- [ ] Stickers
- [ ] Tags
- [ ] Blinds
- [ ] Stakes
- Modded types
  - ...?

## Planned features
Subject to change!

### Data exporting
- [X] Individual sprite exporting 
- [X] Indivudual sprite exporting with layers
- [ ] Individual animated sprite exporting
- [X] Individual shaded sprite exporting
- [X] Individual description exporting
### Formatting
- [X] Balatro localization to wikitext transcriber
- [X] Auto-infoboxes
- [X] Auto-item lists (wikitext tables)
- [X] Prepare item registers
- [ ] Support for other export formats
### Quality of life
- [X] Custom UI for export processing
- [X] Item mass-exporting
- [ ] Resolution selection
- [ ] Vanilla support
- [ ] Malverk texture pack support
- [ ] Auto-update pages/infoboxes/etc. with MediaWiki API? (Admin exclusive)
### Smaller features
- [X] Undefined text-bg combination colllection
- [X] Logging to in-stage log