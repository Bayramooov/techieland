// Nodejs encryption with CTR
const crypto = require('crypto');
const algorithm = 'aes-256-cbc';
// const key = crypto.randomBytes(32);
// const iv = crypto.randomBytes(16);
const key = Buffer.from('846337ba96d94b457fc49132f9d80f5d8d2165262b47954f0673d3975926d2dd', 'hex');
const iv = Buffer.from('770f283d96ec0f2acabcd6edb3500273', 'hex');

function encrypt(pureText) {
  let cipher = crypto.createCipheriv(algorithm, key, iv);
  let encrypted = cipher.update(pureText);
  encrypted = Buffer.concat([encrypted, cipher.final()]);
  return encrypted.toString('hex');
}

function decrypt(encText) {
  let encryptedText = Buffer.from(encText, 'hex');
  let decipher = crypto.createDecipheriv(algorithm, key, iv);
  let decrypted = decipher.update(encryptedText);
  decrypted = Buffer.concat([decrypted, decipher.final()]);
  return decrypted.toString();
}

function e(text) {
  console.log(encrypt(text));
}

function d(encText) {
  console.log(decrypt(encText));
}

e('Sardor Bayramov - +997977771224 this is my << @phone number');
d('66f0a5b5f271ead55d79dad1152f04a8f4f3352ad0dc835fc73d3e653ec484a725943d5fc5b295b0babc9d77b2608c497cbbaec5468487feb9585ad5891b5d43');
