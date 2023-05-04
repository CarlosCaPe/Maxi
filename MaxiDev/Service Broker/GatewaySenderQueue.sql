CREATE QUEUE [QueueSW].[GatewaySenderQueue]
    WITH ACTIVATION (STATUS = ON, PROCEDURE_NAME = [dbo].[sp_ReceiptGatewayMessageReader], MAX_QUEUE_READERS = 2, EXECUTE AS N'dbo');

