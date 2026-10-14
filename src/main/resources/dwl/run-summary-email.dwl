%dw 2.0
output text/plain
var r = vars.runSummaryData default {}
---
"Hello Master Data Team,\n\n" ++
"The product and price book synchronisation run has completed.\n\n" ++
"Run Id: " ++ (r.runId default "unknown") ++ "\n" ++
"Trigger: " ++ (r.triggerType default "unknown") ++ "\n" ++
"Scope: " ++ (r.scope default "unknown") ++ "\n" ++
"Run Status: " ++ (r.status default "unknown") ++ "\n" ++
"Duration: " ++ ((r.durationSeconds default 0) as String) ++ " seconds\n" ++
"Records Read: " ++ ((r.recordsRead default 0) as String) ++ "\n" ++
"Products Created/Updated: " ++ ((r.createdCount default 0) as String) ++ "\n" ++
"Products Deactivated: " ++ ((r.deactivatedCount default 0) as String) ++ "\n" ++
"Records Retried: " ++ ((r.retriedCount default 0) as String) ++ "\n" ++
"Permanent Failures: " ++ ((r.failedCount default 0) as String) ++ "\n" ++
(if (!isEmpty(r.sfCaseNumber default "")) "Salesforce Case Number: " ++ (r.sfCaseNumber as String) ++ "\n" else "") ++
(if (!isEmpty(r.rejectsFile default "")) "Rejects File: " ++ (r.rejectsFile as String) ++ "\n" else "") ++
"Correlation Id: " ++ (r.correlationId default "unknown") ++ "\n\n" ++
"Regards,\nCatalog Integration Service"
