CREATE FULLTEXT INDEX ON [dbo].[Customer]
    ([Name] LANGUAGE 1033, [FirstLastName] LANGUAGE 1033, [SecondLastName] LANGUAGE 1033, [PhoneNumber] LANGUAGE 1033, [CelullarNumber] LANGUAGE 1033)
    KEY INDEX [PK_Customer]
    ON [CustomerInfo]
    WITH STOPLIST OFF;


GO
CREATE FULLTEXT INDEX ON [dbo].[Beneficiary]
    ([Name] LANGUAGE 1033, [FirstLastName] LANGUAGE 1033, [SecondLastName] LANGUAGE 1033)
    KEY INDEX [PK_Beneficiary]
    ON [CustomerInfo];


GO
CREATE FULLTEXT INDEX ON [dbo].[OFAC_SDN]
    ([SDN_name] LANGUAGE 1033)
    KEY INDEX [PK_OFAC_SDN]
    ON [OFAC];


GO
CREATE FULLTEXT INDEX ON [dbo].[OFAC_ALT]
    ([alt_name] LANGUAGE 1033)
    KEY INDEX [PK_OFAC_ALT]
    ON [OFAC];


GO
CREATE FULLTEXT INDEX ON [dbo].[Location]
    ([LocationName] LANGUAGE 1033, [AL1] LANGUAGE 1033, [AL2] LANGUAGE 1033, [AL3] LANGUAGE 1033)
    KEY INDEX [PK_Location]
    ON [LocationCatalog];

