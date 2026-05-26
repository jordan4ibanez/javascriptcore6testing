const { SourceMapConsumer } = require('source-map');
const fs = require('fs');

const [,, mapPath, line, col] = process.argv;

async function resolvePosition() {
    const rawSourceMap = JSON.parse(fs.readFileSync(mapPath, 'utf8'));

    await SourceMapConsumer.with(rawSourceMap, null, (consumer) => {
        const pos = consumer.originalPositionFor({
            line: parseInt(line),
            column: parseInt(col)
        });

        process.stdout.write(`${pos.source} ${pos.line} ${pos.column}`);
    });
}

resolvePosition().catch(err => console.error(err));