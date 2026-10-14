%dw 2.0
output application/json
var run = vars.runRecord
var records = vars.logRecords default []
---
{
    runId: run.run_id,
    triggerType: run.trigger_type,
    scope: run.scope default "FULL",
    status: run.run_status,
    requestedBy: run.requested_by,
    recordsRead: run.records_read default 0,
    createdCount: run.created_count default 0,
    failedCount: run.failed_count default 0,
    correlationId: run.correlation_id,
    startedAt: run.started_at,
    completedAt: run.completed_at,
    records: records map (r) -> {
        erpCode: r.erp_code,
        operation: r.operation,
        recordStatus: r.record_status,
        salesforceId: r.salesforce_id,
        pricebookEntryId: r.pricebook_entry_id,
        errorCode: r.error_code,
        errorMessage: r.error_message,
        processedAt: r.processed_at
    }
}
