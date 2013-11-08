Leopold
=========================

Virtual Assistant for Ubuntu, Mac, Raspberry Pi, and more! Writing in Python and Node.js.

## Features
- [Node.js](http://nodejs.org/) & [Python](http://www.python.org/) server 
- [JavaScript Client SDK (requires running the Node.js server)](https://github.com/Glavin001/Leopold/issues/41)
- Supports Mac and Linux (Ubuntu)

-----

#### Important: Leopold is no longer backwards compatible with [Palaver](https://github.com/JamezQ/Palaver).

-----

## Installation
Run the following Terminal command.
### 1) SSH
```bash
git clone git@github.com:Glavin001/Leopold.git && cd Leopold && ./install
```
#### Troubleshooting
If you receive the following error:
```bash
Permission denied (publickey).
fatal: Could not read from remote repository.

Please make sure you have the correct access rights
and the repository exists.
```
Then use method 2, `HTTP`, instead.
### 2) HTTP
```bash
git clone https://github.com/Glavin001/Leopold.git && cd Leopold && ./install
```

-----

## Usage
#### Node.js Server & JavaScript Websocket SDK
Start Node.js Leopold server:
```bash
node server/server.js
```
Start test webpage with JavaScript API:
```bash
cd server && python -m SimpleHTTPServer
```
then open
`http://localhost:8080/test.html`


### Mac
Coming soon.

### Ubuntu
Coming soon.

### Other
Suggest an Operating System to test in the Issues. Also, if you have tested Leopold on another Operating System and it does or does not working, I'd love to hear of your findings! Thanks for the support.
