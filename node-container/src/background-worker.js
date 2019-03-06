'use strict';

const mp = require('./mysql-promise');

const someRandomRask = require('./some-random-task');

const AsyncFunctions = [
    someRandomTask,
];

async function main() {
    var res = [];
    AsyncFunctions.forEach(func => {
        res.push(func());
    });

    let allResolved = null;
    try {
        allResolved = await Promise.all(res);
    } catch (err) {
        console.error(err);
    }

    return allResolved;
}

main().then((r) => {
    //console.log(`Resolved into: ${JSON.stringify(r)}`);
    return mp.shutdownConnectionPool();
}).then((err) => {
    if (err) {
        console.error(err);
    }
    return err;
}).catch((err) => {
    console.error(err);
})
