CREATE TABLE [DTOne].[Carrier] (
    [IdCarrier]        INT         IDENTITY (1, 1) NOT NULL,
    [IdCountry]        INT         NULL,
    [CarrierName]      NCHAR (150) NOT NULL,
    [DateOfCreation]   DATETIME    NOT NULL,
    [DateOfLastChange] DATETIME    NOT NULL,
    [EnterByIdUser]    INT         NOT NULL,
    [IdCarrierDTO]     INT         NULL,
    [IdGenericStatus]  INT         NULL,
    CONSTRAINT [PK_TransferDTOCarrier] PRIMARY KEY CLUSTERED ([IdCarrier] ASC) WITH (FILLFACTOR = 90)
);

