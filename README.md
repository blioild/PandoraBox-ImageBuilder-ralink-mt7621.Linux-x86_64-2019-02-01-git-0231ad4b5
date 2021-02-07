# How to use:
### Ubuntu ###
- Install dependencies:
```bash
sudo apt-get update
```
```bash
sudo apt-get install vim golang npm build-essential libncurses5-dev zlib1g-dev gawk git libssl-dev wget unzip python ocaml-nox help2man texinfo yui-compressor
```
note: You need to install those packages above one by one when you have problem with them.
- Clone ImageBuilder to you Ubuntu and go to the ImageBuiler directory
- Generate .profiles.mk
```bash
make info
```
- Find your device in .profiles.mk and modify .profiles.mk
```bash
vim .profiles.mk
```
- Generate Image for you device
```bash
make image PROFILE=xiaomi-r3g
```
You can add FIELS=files/ after make image command
then all the files in files directory will be add to the root directory of you image
