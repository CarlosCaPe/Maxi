CREATE TABLE [dbo].[ClaimCodeProfile] (
    [ProfileKey]           NVARCHAR (50) NOT NULL,
    [Prefix]               NVARCHAR (50) NOT NULL,
    [RandomCharacters]     INT           NOT NULL,
    [AcceptableCharacters] NVARCHAR (50) NOT NULL,
    [FixedLength]          BIT           NOT NULL,
    [Length]               TINYINT       NULL,
    [Filler]               CHAR (1)      NULL,
    [IncludePrefix]        BIT           NOT NULL,
    [FixedRange]           BIT           NULL,
    [MinRange]             BIGINT        NULL,
    [MaxRange]             BIGINT        NULL,
    [CurrentNumber]        BIGINT        NULL,
    CONSTRAINT [PK_ClaimCodeProfile] PRIMARY KEY CLUSTERED ([ProfileKey] ASC)
);

