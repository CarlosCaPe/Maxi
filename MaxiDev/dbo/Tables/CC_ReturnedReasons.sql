CREATE TABLE [dbo].[CC_ReturnedReasons] (
    [ReturnedReason_ID]  INT           IDENTITY (1, 1) NOT NULL,
    [RTR_Name]           VARCHAR (100) NULL,
    [RTR_ASCX9]          VARCHAR (10)  NULL,
    [RTR_X9ShortName]    VARCHAR (100) NULL,
    [RTR_X9Abbreviation] VARCHAR (100) NULL,
    [CanReProcessCheck]  BIT           DEFAULT ((0)) NOT NULL,
    [CanRePrintCheck]    BIT           DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_CC_ReturnReasons] PRIMARY KEY CLUSTERED ([ReturnedReason_ID] ASC)
);

