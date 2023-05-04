CREATE TABLE [dbo].[CertificateMachineData] (
    [IdMachineData]           INT           IDENTITY (1, 1) NOT NULL,
    [IdAgent]                 INT           NOT NULL,
    [IdUser]                  INT           NOT NULL,
    [AgentVersion]            VARCHAR (MAX) NOT NULL,
    [MacAddress]              VARCHAR (MAX) NOT NULL,
    [SerialMotherBoard]       VARCHAR (MAX) NOT NULL,
    [WithCertificate]         BIT           NOT NULL,
    [DateLoggedData]          DATETIME      DEFAULT (NULL) NULL,
    [DateDetectedCertificate] DATETIME      DEFAULT (NULL) NULL,
    CONSTRAINT [PK_CertificateMachineData] PRIMARY KEY CLUSTERED ([IdMachineData] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_CertificateMachineData_IdAgent]
    ON [dbo].[CertificateMachineData]([IdAgent] ASC);

