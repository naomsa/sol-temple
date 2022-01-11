# 🌞 Sol Temple 🏛

<p align="center">
  <img src="https://4.bp.blogspot.com/-4sOEVk4LarM/TWXYDpnpwcI/AAAAAAAAFUs/0qc4IZlpjkM/s1600/e781308e.JPG"/>
</p>

**A collection of reusable contracts** for deploying your own Solidity projects. The main focus is to provide gas efficient code, but as the code was not audited yet, no one can guarantee you it's gonna work. **Do your own research and act with responsability.**

## Disclaimer

The **ERC721** contract is so powerful and cheap because of it's ability to read data dynamically, without the need to store, but, in a trade off, it's view functions such as **ownerOf** and **balanceOf** defined on the standard, read much more data at the same time and can be unreliable to implementations like yield tokens because storage loading is expensive may lead to out of gas external calls.
