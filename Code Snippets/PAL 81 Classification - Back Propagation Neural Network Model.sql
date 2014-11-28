-- cleanup
DROP TYPE "T_DATA";
DROP TYPE "T_PARAMS";
DROP TYPE "T_STATS";
DROP TYPE "T_MODEL";
DROP TABLE "SIGNATURE";
CALL "SYS"."AFLLANG_WRAPPER_PROCEDURE_DROP"('DEVUSER', 'P_BPNN_M');
DROP VIEW "V_DATA";
DROP TABLE "STATS";
DROP TABLE "MODEL";

-- procedure setup
CREATE TYPE "T_DATA" AS TABLE ("POLICY" VARCHAR(10), "AGE" INTEGER, "AMOUNT" INTEGER, "OCCUPATION" VARCHAR(10), "FRAUD" VARCHAR(10));
CREATE TYPE "T_PARAMS" AS TABLE ("NAME" VARCHAR(60), "INTARGS" INTEGER, "DOUBLEARGS" DOUBLE, "STRINGARGS" VARCHAR(100));
CREATE TYPE "T_STATS" AS TABLE ("NAME" VARCHAR(100), "VALUE" DOUBLE);
CREATE TYPE "T_MODEL" AS TABLE ("NAME" VARCHAR(100), "MODEL" CLOB);

CREATE COLUMN TABLE "SIGNATURE" ("POSITION" INTEGER, "SCHEMA_NAME" VARCHAR(100), "TYPE_NAME" VARCHAR(100), "PARAMETER_TYPE" VARCHAR(100));
INSERT INTO "SIGNATURE" VALUES (1, 'DEVUSER', 'T_DATA', 'IN');
INSERT INTO "SIGNATURE" VALUES (2, 'DEVUSER', 'T_PARAMS', 'IN');
INSERT INTO "SIGNATURE" VALUES (3, 'DEVUSER', 'T_STATS', 'OUT');
INSERT INTO "SIGNATURE" VALUES (4, 'DEVUSER', 'T_MODEL', 'OUT');

CALL "SYS"."AFLLANG_WRAPPER_PROCEDURE_CREATE"('AFLPAL', 'CREATEBPNN', 'DEVUSER', 'P_BPNN_M', "SIGNATURE");

-- data & view setup
CREATE VIEW "V_DATA" AS
 SELECT "POLICY", "AGE", "AMOUNT", "OCCUPATION", "FRAUD" 
  FROM "PAL"."CLAIMS"
  ;
CREATE COLUMN TABLE "STATS" LIKE "T_STATS";
CREATE COLUMN TABLE "MODEL" LIKE "T_MODEL";

-- runtime
DROP TABLE "#PARAMS";
CREATE LOCAL TEMPORARY COLUMN TABLE "#PARAMS" LIKE "T_PARAMS";
INSERT INTO "#PARAMS" VALUES ('HIDDEN_LAYER_ACTIVE_FUNC', 1, null, null);
INSERT INTO "#PARAMS" VALUES ('OUTPUT_LAYER_ACTIVE_FUNC', 1, null, null);
INSERT INTO "#PARAMS" VALUES ('LEARNING_RATE', null, 0.001, null);
INSERT INTO "#PARAMS" VALUES ('MOMENTUM_FACTOR', null, 0.00001, null);
INSERT INTO "#PARAMS" VALUES ('HIDDEN_LAYER_SIZE', null, null, '10,10');
--INSERT INTO "#PARAMS" VALUES ('MAX_ITERATION', 100, null, null);
--INSERT INTO "#PARAMS" VALUES ('FUNCTIONALITY', 0, null, null); -- 0:Classification; 1:Regression
--INSERT INTO "#PARAMS" VALUES ('TARGET_COLUMN_NUM', 1, null, null);
--INSERT INTO "#PARAMS" VALUES ('TRAINING_STYLE', 1, null, null); -- 0:Batch; 1:Stochastic
--INSERT INTO "#PARAMS" VALUES ('NORMALIZATION', 0, null, null); -- 0:Normal; 1:Z-transform; 2:Scalar
--INSERT INTO "#PARAMS" VALUES ('WEIGHT_INIT', 0, null, null); -- 0:all zeros; 1: normal; 2: uniform
--INSERT INTO "#PARAMS" VALUES ('CATEGORY_COL', 0, null, null);

TRUNCATE TABLE "STATS";
TRUNCATE TABLE "MODEL";

CALL "P_BPNN_M" ("V_DATA", "#PARAMS", "STATS", "MODEL") WITH OVERVIEW;

SELECT * FROM "STATS";
SELECT * FROM "MODEL";
