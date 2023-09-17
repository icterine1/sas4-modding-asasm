# SAS4 Modding .asasm Files

This repository is a stand-in for a working actionscript project.

## Contents

### High-level Overview

`sas4_asasm` can be thought of as the "source code", but in AS3 assembly rather than real Actionscript3.

Storing assembly instead of full SWFs in a Git repository has multiple benefits:

* Can see which packages were changed in a commit
* Can merge changes from different branches
* Can easily reuse the same bytecode for SWFs with different assets

[FFDec](https://github.com/jindrapetrik/jpexs-decompiler/tree/master) will still be used to edit the SWF. The purpose of disassembling the SWF is to enable better integration with Git.

`static_swf` can be thought of as storing the assets for the SAS4 SWF(s).

`asm_swf.ps1` and `disasm_swf.ps1` are scripts for assembling and disassembling SWFs respectively.

### Details

* `sas4_asasm` - Disassembled bytecode of the current SWF. Typically generated using the `disasm_swf.ps1` script.
* `static_swf` - SWF files with sprites, shapes, binary data, etc, but no code. The `asm_swf.ps1` script will copy and add bytecode to these SWFs to make them functional.
* `build` - contains the functional SWFs created by the `asm_swf.ps1` script. Not included in the repository and only created after running `asm_swf.ps1`.
* `asm_swf.ps1` - Assembles functional SWFs using the asset-only SWFs in `static_swf` and the actionscript assembly files in `sas4_asasm`. More specifically, for each SWF in `static_swf`, the script will create a functional copy of that SWF in `build`, using the bytecode assembled from `sas4_asasm`
* `disasm_swf.ps1` - Replaces the contents of the `sas4_asasm` directory with the result of disassembling a specified SWF. Specify an SWF using the `--src` argument.

`asm_swf.ps1` and `disasm_swf.ps1` use [RABCDasm](https://github.com/CyberShadow/RABCDAsm) to assemble/disassemble AS3 bytecode.

### `static-swf` Contents

* `sas4.swf` - Contains assets for the sitelock-removed SAS4 SWF. In other words, identical to the assets of the original SAS4 SWF, aside from removing the "Play this game on ninjakiwi.com" text in the opening screen.
* `sas4_short_op.swf` - The same as `sas4.swf`, but with the opening animation cut short.

## Workflow

### Pulling changes/Playing the SWF

After pulling this repository, you can build the SWF by running `asm_swf.ps1`. Afterwards, SWFs should be created in the `build` folder, which you can play in Flash Projector (or any other means of opening SWFs).

### Editing the SWF

While it is technically possible to edit the raw `.asasm` files, doing so is quite tedious. It is recommended to build the SWF (see previous section for details) and then edit it using FFDec.

### Pushing changes

Once you feel like pushing your changes, you must update  `sas4_asasm` accordingly; in other words, disassemble the SWF you just edited. This can be done by running `disasm_swf.ps1 --src <path to swf you edited>`

### Merge conflicts

In general, try to structure branches and Git history in a way that avoids merge conflicts. Even if there are no merge conflicts, you should still open the SWF in FFDec to make sure the modified packages look right. If you do encounter merge conflicts, resolving them by going through the `.asasm` files is likely going to be very messy. It's probably better to open the SWF of each branch in FFDec and look at the decompiled Actionscript of each package that has merge conflicts to figure out how to resolve them.

## Setup/Dependencies

### Running the scripts

It is highly recommended to use [Powershell 7](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows?view=powershell-7.3) to run the powershell scripts. Windows by default comes with Powershell 5, which may still work, but compatibility with Powershell 5 is not maintained.

You must have [RABCDasm](https://github.com/CyberShadow/RABCDAsm) installed (make sure it is in your PATH) for the scripts to work.

### Git Config

After cloning the repository, run `git config --local include.path ../.git_config` so that the Git config settings in `.git_config` get applied.

### Other

Use [FFDec](https://github.com/jindrapetrik/jpexs-decompiler/tree/master) to decompile, inspect, edit, and debug SWF files.

Play the SWF using the [Standalone Flash Projector](https://archive.org/details/adobe-flash-player-projector). You will need to use the persistence.swf method to log in.

The [Debug Flash Projector](https://archive.org/details/flashplayer_32_sa_debug_2) can be useful for debugging and viewing errors, but it runs significantly slower.
