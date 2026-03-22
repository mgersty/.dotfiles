# To Update Key Mappings

1. Install QMK cli tool
2. Setup: <code>qmk setup</code>
3. Create new mapping: <code>qmk new-keymap -kb crkbd -km [ new keyboard name directory ]</code>
4. Make changes to [new keyboard name directory]/keymap.c
5. Compile <code>qmk compile -kb crkbd -km [ new keyboard name directory ]</code>
6. Flash <code>qmk flash -kb crkbd/rev1 [ hex file created from compilation ]</code>

```bash
qmk setup
qmk new-keymap -kb crkbd -km new.keymap
qmk compile -kb crkbd -km new.keymap
qmk flash -kb crkbd/rev1 ~/qmk_firmware/.build/hex file
```

