#!/usr/bin/env node

const { ProgramBuilder, DiagnosticSeverity } = require('brighterscript');
const { groupBy } = require('lodash');

module.exports = (async function () {
    const builder = new ProgramBuilder();
    await builder.run({
        project: process.argv[2] || "bsconfig.json"
    });

    const diagnostics = groupBy(builder.program.getDiagnostics(), 'severity');
    const errors = diagnostics[DiagnosticSeverity.Error] || { length: 0 };

    return process.exit(errors.length);
}());
