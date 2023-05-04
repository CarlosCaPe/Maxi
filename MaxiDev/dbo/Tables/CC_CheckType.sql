CREATE TABLE [dbo].[CC_CheckType] (
    [IdCheckType]    INT          IDENTITY (1, 1) NOT NULL,
    [CT_DateCreated] DATETIME     CONSTRAINT [DF_CC_CheckType_CT_DateCreated] DEFAULT (getdate()) NOT NULL,
    [CT_Name]        VARCHAR (50) NOT NULL,
    [CT_Active]      BIT          CONSTRAINT [DF_Table_1_CT_Status] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_CC_CheckType] PRIMARY KEY CLUSTERED ([IdCheckType] ASC)
);

