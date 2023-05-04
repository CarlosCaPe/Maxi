CREATE TABLE [Corp].[MultiIRDPrintReport] (
    [IdMultiIRDPrintReport] INT            IDENTITY (1, 1) NOT NULL,
    [ReportGUID]            VARCHAR (50)   NULL,
    [ImgBytes]              VARCHAR (MAX)  NULL,
    [ReportText]            VARCHAR (MAX)  NULL,
    [ImgOrder]              INT            NULL,
    [IsCheckImg]            BIT            NULL,
    [MaxiLine1]             NVARCHAR (100) NULL,
    [MaxiLine2]             NVARCHAR (100) NULL,
    [MaxiLine3]             NVARCHAR (100) NULL,
    [AgentLine1]            NVARCHAR (100) NULL,
    [AgentLine2]            NVARCHAR (100) NULL,
    [AgentLine3]            NVARCHAR (100) NULL,
    [CreationDate]          DATETIME       DEFAULT (getdate()) NULL
);

