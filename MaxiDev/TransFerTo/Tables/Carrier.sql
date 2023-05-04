CREATE TABLE [TransFerTo].[Carrier] (
    [IdCarrier]        INT         IDENTITY (1, 1) NOT NULL,
    [IdCountry]        INT         NOT NULL,
    [CarrierName]      NCHAR (150) NOT NULL,
    [DateOfCreation]   DATETIME    NOT NULL,
    [DateOfLastChange] DATETIME    NOT NULL,
    [EnterByIdUser]    INT         NOT NULL,
    [IdCarrierTTo]     INT         NULL,
    [IdGenericStatus]  INT         NULL,
    CONSTRAINT [PK_TransferTToCarrier] PRIMARY KEY CLUSTERED ([IdCarrier] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_TToCarrier_TToCountry] FOREIGN KEY ([IdCountry]) REFERENCES [TransFerTo].[Country] ([IdCountry]),
    CONSTRAINT [FK_TToCarrier_User] FOREIGN KEY ([EnterByIdUser]) REFERENCES [dbo].[Users] ([IdUser])
);


GO
CREATE NONCLUSTERED INDEX [IDX_Carrier_IdCarrierTTo]
    ON [TransFerTo].[Carrier]([IdCarrierTTo] ASC);

