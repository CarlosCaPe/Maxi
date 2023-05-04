CREATE TABLE [report].[CharacterWidth] (
    [FontName]   VARCHAR (31) NOT NULL,
    [FontBold]   INT          NOT NULL,
    [FontItalic] INT          NOT NULL,
    [CODE]       INT          NOT NULL,
    [Length]     FLOAT (53)   NULL,
    CONSTRAINT [PK_CharacterWidth] PRIMARY KEY CLUSTERED ([FontName] ASC, [FontBold] ASC, [FontItalic] ASC, [CODE] ASC)
);

