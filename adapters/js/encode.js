const Hashids = require('../../vendor/hashids.js/dist/hashids');

if (typeof process.env.HASHIDS_SALT === 'undefined') {
    throw new TypeError("'HASHIDS_SALT' is required")
}

if (typeof process.env.HASHIDS_MIN_LENGTH === 'undefined') {
    throw new TypeError("'HASHIDS_MIN_LENGTH' is required")
}

if (typeof process.env.HASHIDS_ID === 'undefined') {
    throw new TypeError("'HASHIDS_ID' is required")
}

// required
const salt = process.env.HASHIDS_SALT;
const minLength = parseInt(process.env.HASHIDS_MIN_LENGTH, 10);

// optional
const alphabet = process.env.HASHIDS_ALPHABET;

const id = parseInt(process.env.HASHIDS_ID, 10);

const hashids = new Hashids(salt, minLength, alphabet);
console.log(hashids.encode(id));
