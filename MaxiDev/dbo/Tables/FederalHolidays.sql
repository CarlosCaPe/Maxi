CREATE TABLE [dbo].[FederalHolidays] (
    [IdDay]       INT           IDENTITY (1, 1) NOT NULL,
    [Day]         DATE          NOT NULL,
    [Description] NVARCHAR (50) NULL,
    [Enabled]     BIT           CONSTRAINT [DF_FederalHolidays_Enabled] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_FederalHolidays] PRIMARY KEY CLUSTERED ([IdDay] ASC)
);

