CREATE TABLE [dbo].[ClaimCodeProfileForApi] (
    [ProfileKey]    NVARCHAR (50) NOT NULL,
    [CreationDate]  DATETIME      DEFAULT (getdate()) NULL,
    [ActiveProfile] BIT           NULL,
    PRIMARY KEY CLUSTERED ([ProfileKey] ASC)
);

