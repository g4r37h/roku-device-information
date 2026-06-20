import { BscFile, CompilerPlugin, DiagnosticSeverity, isBrsFile, NullCoalescingExpression, TokenKind } from 'brighterscript';

export default function () {
    return {
        name: 'nco-parentheses-linter',
        afterFileValidate: (file: BscFile) => {
            if (isBrsFile(file)) {
                file.parser.references.expressions.forEach((expression) => {

                    if (!(expression instanceof NullCoalescingExpression)) {
                        return;
                    }

                    if (expression.range && file.getTokenAt(expression.range.start)?.kind !== TokenKind.LeftParen) {
                        file.addDiagnostics([{
                            code: 9001,
                            severity: DiagnosticSeverity.Error,
                            message: 'Null coalescing expressions should be wrapped with parentheses to avoid unintended behavior.',
                            range: expression.range,
                            file
                        }]);
                    };
                });
            }
        }
    } as CompilerPlugin;
};
