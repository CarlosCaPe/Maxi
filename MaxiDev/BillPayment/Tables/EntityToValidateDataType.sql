CREATE TABLE [BillPayment].[EntityToValidateDataType] (
    [IdDataType]  INT           IDENTITY (1, 1) NOT NULL,
    [DataType]    VARCHAR (500) NOT NULL,
    [IsTypeRange] BIT           NOT NULL
);

