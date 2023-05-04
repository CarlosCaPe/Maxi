CREATE TABLE [dbo].[TNC_CLAIM_CODE_PAYERS_BK191113] (
    [payer_name]                  NVARCHAR (50) NOT NULL,
    [payer_prefix]                NVARCHAR (50) NOT NULL,
    [payer_random_characters]     INT           NOT NULL,
    [payer_acceptable_characters] NVARCHAR (50) NOT NULL,
    [payer_fixed_length]          BIT           NOT NULL,
    [payer_length_no]             TINYINT       NULL,
    [payer_filler]                CHAR (1)      NULL,
    [payer_include_prefix]        BIT           NOT NULL,
    [payer_fixed_range]           BIT           NULL,
    [payer_min_range]             BIGINT        NULL,
    [payer_max_range]             BIGINT        NULL,
    [payer_current_number]        BIGINT        NULL
);

