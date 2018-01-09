CREATE TABLE IDN_BASE_TABLE (
            PRODUCT_NAME VARCHAR (20) NOT NULL,
            PRIMARY KEY (PRODUCT_NAME))
/
INSERT INTO IDN_BASE_TABLE values ('WSO2 Identity Server')
/
CREATE TABLE IDN_OAUTH_CONSUMER_APPS (
            ID INTEGER NOT NULL,
            CONSUMER_KEY VARCHAR (255) NOT NULL,
            CONSUMER_SECRET VARCHAR (512),
            USERNAME VARCHAR (255),
            TENANT_ID INTEGER DEFAULT 0,
            USER_DOMAIN VARCHAR(50),
            APP_NAME VARCHAR (255),
            OAUTH_VERSION VARCHAR (128),
            CALLBACK_URL VARCHAR (1024),
            GRANT_TYPES VARCHAR (1024),
            PKCE_MANDATORY CHAR(1) DEFAULT '0',
            PKCE_SUPPORT_PLAIN CHAR(1) DEFAULT '0',
            APP_STATE VARCHAR (25) DEFAULT 'ACTIVE',
            USER_ACCESS_TOKEN_EXPIRE_TIME BIGINT DEFAULT 3600000,
            APP_ACCESS_TOKEN_EXPIRE_TIME BIGINT DEFAULT 3600000,
            REFRESH_TOKEN_EXPIRE_TIME BIGINT DEFAULT 84600000,
            CONSTRAINT CONSUMER_KEY_CONSTRAINT UNIQUE (CONSUMER_KEY),
            PRIMARY KEY (ID))
/
CREATE SEQUENCE IDN_OAUTH_CONSUMER_APPS_SEQUENCE START WITH 1 INCREMENT BY 1 NOCACHE
  /
CREATE TRIGGER IDN_OAUTH_CONSUMER_APPS_TRIGGER NO CASCADE BEFORE INSERT ON IDN_OAUTH_CONSUMER_APPS
REFERENCING NEW AS NEW FOR EACH ROW MODE DB2SQL
  BEGIN ATOMIC
    SET (NEW.ID)
    = (NEXTVAL FOR IDN_OAUTH_CONSUMER_APPS_SEQUENCE);
  END
/
CREATE TABLE IDN_OAUTH1A_REQUEST_TOKEN (
            REQUEST_TOKEN VARCHAR (512) NOT NULL,
            REQUEST_TOKEN_SECRET VARCHAR (512),
            CONSUMER_KEY_ID INTEGER,
            CALLBACK_URL VARCHAR (1024),
            SCOPE VARCHAR(2048),
            AUTHORIZED VARCHAR (128),
            OAUTH_VERIFIER VARCHAR (512),
            AUTHZ_USER VARCHAR (512),
            TENANT_ID INTEGER DEFAULT -1,
            PRIMARY KEY (REQUEST_TOKEN),
            FOREIGN KEY (CONSUMER_KEY_ID) REFERENCES IDN_OAUTH_CONSUMER_APPS(ID) ON DELETE CASCADE)
/
CREATE TABLE IDN_OAUTH1A_ACCESS_TOKEN (
            ACCESS_TOKEN VARCHAR (512) NOT NULL,
            ACCESS_TOKEN_SECRET VARCHAR (512),
            CONSUMER_KEY_ID INTEGER,
            SCOPE VARCHAR(2048),
            AUTHZ_USER VARCHAR (512),
            TENANT_ID INTEGER DEFAULT -1,
            PRIMARY KEY (ACCESS_TOKEN),
            FOREIGN KEY (CONSUMER_KEY_ID) REFERENCES IDN_OAUTH_CONSUMER_APPS(ID) ON DELETE CASCADE)
/
CREATE TABLE IDN_OAUTH2_ACCESS_TOKEN (
            TOKEN_ID VARCHAR (255) NOT NULL,
            ACCESS_TOKEN VARCHAR (512) NOT NULL,
            REFRESH_TOKEN VARCHAR (512),
            CONSUMER_KEY_ID INTEGER NOT NULL,
            AUTHZ_USER VARCHAR (100) NOT NULL,
            TENANT_ID INTEGER NOT NULL,
            USER_DOMAIN VARCHAR (50) NOT NULL,
            USER_TYPE VARCHAR (25) NOT NULL,
            GRANT_TYPE VARCHAR (50),
            TIME_CREATED TIMESTAMP,
            REFRESH_TOKEN_TIME_CREATED TIMESTAMP,
            VALIDITY_PERIOD BIGINT,
            REFRESH_TOKEN_VALIDITY_PERIOD BIGINT,
            TOKEN_SCOPE_HASH VARCHAR (32) NOT NULL,
            TOKEN_STATE VARCHAR (25) DEFAULT 'ACTIVE' NOT NULL,
            TOKEN_STATE_ID VARCHAR (128) DEFAULT 'NONE' NOT NULL,
            SUBJECT_IDENTIFIER VARCHAR(255),
            PRIMARY KEY (TOKEN_ID),
            FOREIGN KEY (CONSUMER_KEY_ID) REFERENCES IDN_OAUTH_CONSUMER_APPS(ID) ON DELETE CASCADE,
            CONSTRAINT CON_APP_KEY UNIQUE (CONSUMER_KEY_ID,AUTHZ_USER,TENANT_ID,USER_DOMAIN,USER_TYPE,TOKEN_SCOPE_HASH,
                                 TOKEN_STATE,TOKEN_STATE_ID))
/

CREATE INDEX IDX_AT_CK_AU ON IDN_OAUTH2_ACCESS_TOKEN(CONSUMER_KEY_ID, AUTHZ_USER, TOKEN_STATE, USER_TYPE)
/

CREATE INDEX IDX_TC ON IDN_OAUTH2_ACCESS_TOKEN(TIME_CREATED)
/

CREATE INDEX IDX_AT ON IDN_OAUTH2_ACCESS_TOKEN(ACCESS_TOKEN)
/

CREATE TABLE IDN_OAUTH2_AUTHORIZATION_CODE (
            CODE_ID VARCHAR (255) NOT NULL,
            AUTHORIZATION_CODE VARCHAR (512) NOT NULL,
            CONSUMER_KEY_ID INTEGER,
            CALLBACK_URL VARCHAR (1024),
            SCOPE VARCHAR(2048),
            AUTHZ_USER VARCHAR (100) NOT NULL,
            TENANT_ID INTEGER,
            USER_DOMAIN VARCHAR (50) NOT NULL,
            TIME_CREATED TIMESTAMP,
            VALIDITY_PERIOD BIGINT,
            STATE VARCHAR (25) DEFAULT 'ACTIVE',
            TOKEN_ID VARCHAR(255),
            SUBJECT_IDENTIFIER VARCHAR(255),
            PKCE_CODE_CHALLENGE VARCHAR(255),
            PKCE_CODE_CHALLENGE_METHOD VARCHAR(128),
            PRIMARY KEY (CODE_ID),
            FOREIGN KEY (CONSUMER_KEY_ID) REFERENCES IDN_OAUTH_CONSUMER_APPS(ID) ON DELETE CASCADE)
/

CREATE INDEX IDX_AUTHORIZATION_CODE ON IDN_OAUTH2_AUTHORIZATION_CODE (AUTHORIZATION_CODE,CONSUMER_KEY_ID)
/

CREATE TABLE IDN_OAUTH2_ACCESS_TOKEN_SCOPE (
            TOKEN_ID VARCHAR (255) NOT NULL,
            TOKEN_SCOPE VARCHAR (60) NOT NULL,
            TENANT_ID INTEGER DEFAULT -1,
            PRIMARY KEY (TOKEN_ID, TOKEN_SCOPE),
            FOREIGN KEY (TOKEN_ID) REFERENCES IDN_OAUTH2_ACCESS_TOKEN(TOKEN_ID) ON DELETE CASCADE)
/
CREATE TABLE IDN_OAUTH2_SCOPE (
            SCOPE_ID INTEGER NOT NULL,
            NAME VARCHAR(255) NOT NULL,
            DESCRIPTION VARCHAR(512) NOT NULL,
            TENANT_ID INTEGER NOT NULL DEFAULT -1,
            PRIMARY KEY (SCOPE_ID))
/
CREATE SEQUENCE IDN_OAUTH2_SCOPE_SEQUENCE START WITH 1 INCREMENT BY 1 NOCACHE
/
CREATE TRIGGER IDN_OAUTH2_SCOPE_TRIGGER NO CASCADE BEFORE INSERT ON IDN_OAUTH2_SCOPE
REFERENCING NEW AS NEW FOR EACH ROW MODE DB2SQL

BEGIN ATOMIC

    SET (NEW.SCOPE_ID)
       = (NEXTVAL FOR IDN_OAUTH2_SCOPE_SEQUENCE);

END
/
CREATE UNIQUE INDEX SCOPE_INDEX ON IDN_OAUTH2_SCOPE (NAME, TENANT_ID)
/
CREATE TABLE IDN_OAUTH2_SCOPE_BINDING (
            SCOPE_ID INTEGER NOT NULL,
            SCOPE_BINDING VARCHAR(255),
            FOREIGN KEY (SCOPE_ID) REFERENCES IDN_OAUTH2_SCOPE(SCOPE_ID) ON DELETE CASCADE)
/
CREATE TABLE IDN_OAUTH2_RESOURCE_SCOPE (
            RESOURCE_PATH VARCHAR (255) NOT NULL,
            SCOPE_ID INTEGER NOT NULL,
            TENANT_ID INTEGER DEFAULT -1,
            PRIMARY KEY (RESOURCE_PATH),
            FOREIGN KEY (SCOPE_ID) REFERENCES IDN_OAUTH2_SCOPE (SCOPE_ID) ON DELETE CASCADE)
/
CREATE TABLE IDN_SCIM_GROUP (
            ID INTEGER NOT NULL,
            TENANT_ID INTEGER NOT NULL,
            ROLE_NAME VARCHAR(255) NOT NULL,
            ATTR_NAME VARCHAR(1024) NOT NULL,
            ATTR_VALUE VARCHAR(1024),
            PRIMARY KEY (ID))
/
CREATE SEQUENCE IDN_SCIM_GROUP_SEQUENCE START WITH 1 INCREMENT BY 1 NOCACHE
/
CREATE TRIGGER IDN_SCIM_GROUP_TRIGGER NO CASCADE BEFORE INSERT ON IDN_SCIM_GROUP
REFERENCING NEW AS NEW FOR EACH ROW MODE DB2SQL

BEGIN ATOMIC

    SET (NEW.ID)
       = (NEXTVAL FOR IDN_SCIM_GROUP_SEQUENCE);

END
/
CREATE TABLE IDN_OPENID_REMEMBER_ME (
            USER_NAME VARCHAR(255) NOT NULL,
            TENANT_ID INTEGER DEFAULT 0 NOT NULL,
            COOKIE_VALUE VARCHAR(1024),
            CREATED_TIME TIMESTAMP,
            PRIMARY KEY (USER_NAME, TENANT_ID))
/
CREATE TABLE IDN_OPENID_USER_RPS (
			USER_NAME VARCHAR(255) NOT NULL,
			TENANT_ID INTEGER DEFAULT 0 NOT NULL,
			RP_URL VARCHAR(255) NOT NULL,
			TRUSTED_ALWAYS VARCHAR(128) DEFAULT 'FALSE',
			LAST_VISIT DATE NOT NULL,
			VISIT_COUNT INTEGER DEFAULT 0,
			DEFAULT_PROFILE_NAME VARCHAR(255) DEFAULT 'DEFAULT',
			PRIMARY KEY (USER_NAME, TENANT_ID, RP_URL))
/
CREATE TABLE IDN_OPENID_ASSOCIATIONS (
			HANDLE VARCHAR(255) NOT NULL,
			ASSOC_TYPE VARCHAR(255) NOT NULL,
			EXPIRE_IN TIMESTAMP NOT NULL,
			MAC_KEY VARCHAR(255) NOT NULL,
			ASSOC_STORE VARCHAR(128) DEFAULT 'SHARED',
			TENANT_ID INTEGER DEFAULT -1,
			PRIMARY KEY (HANDLE))
/
CREATE TABLE IDN_STS_STORE (
            ID INTEGER NOT NULL,
            TOKEN_ID VARCHAR(255) NOT NULL,
            TOKEN_CONTENT BLOB NOT NULL,
            CREATE_DATE TIMESTAMP NOT NULL,
            EXPIRE_DATE TIMESTAMP NOT NULL,
            STATE INTEGER DEFAULT 0,
            PRIMARY KEY (ID))
/
CREATE SEQUENCE IDN_STS_STORE_SEQUENCE START WITH 1 INCREMENT BY 1 NOCACHE
/
CREATE TRIGGER IDN_STS_STORE_TRIGGER NO CASCADE BEFORE INSERT ON IDN_STS_STORE
REFERENCING NEW AS NEW FOR EACH ROW MODE DB2SQL

BEGIN ATOMIC

    SET (NEW.ID)
       = (NEXTVAL FOR IDN_STS_STORE_SEQUENCE);

END
/
CREATE TABLE IDN_IDENTITY_USER_DATA (
            TENANT_ID INTEGER DEFAULT -1234 NOT NULL,
            USER_NAME VARCHAR(255) NOT NULL,
            DATA_KEY VARCHAR(255) NOT NULL,
            DATA_VALUE VARCHAR(2048),
            PRIMARY KEY (TENANT_ID, USER_NAME, DATA_KEY))
/
CREATE TABLE IDN_IDENTITY_META_DATA (
            USER_NAME VARCHAR(255) NOT NULL,
            TENANT_ID INTEGER DEFAULT -1234 NOT NULL,
            METADATA_TYPE VARCHAR(255) NOT NULL,
            METADATA VARCHAR(255) NOT NULL,
            VALID VARCHAR(255) NOT NULL,
            PRIMARY KEY (TENANT_ID, USER_NAME, METADATA_TYPE,METADATA))
/
CREATE TABLE IDN_THRIFT_SESSION (
            SESSION_ID VARCHAR(255) NOT NULL,
            USER_NAME VARCHAR(255) NOT NULL,
            CREATED_TIME VARCHAR(255) NOT NULL,
            LAST_MODIFIED_TIME VARCHAR(255) NOT NULL,
            TENANT_ID INTEGER DEFAULT -1,
            PRIMARY KEY (SESSION_ID)
)
/

CREATE TABLE IDN_AUTH_SESSION_STORE (
            SESSION_ID VARCHAR (100) NOT NULL,
            SESSION_TYPE VARCHAR(100) NOT NULL,
            OPERATION VARCHAR(10) NOT NULL,
            SESSION_OBJECT BLOB,
            TIME_CREATED BIGINT NOT NULL,
            TENANT_ID INTEGER DEFAULT -1,
            PRIMARY KEY (SESSION_ID, SESSION_TYPE, TIME_CREATED, OPERATION)
)
/
CREATE TABLE SP_APP (
        ID INTEGER NOT NULL,
        TENANT_ID INTEGER NOT NULL,
        APP_NAME VARCHAR (255) NOT NULL ,
        USER_STORE VARCHAR (255) NOT NULL,
        USERNAME VARCHAR (255) NOT NULL ,
        DESCRIPTION VARCHAR (1024),
        ROLE_CLAIM VARCHAR (512),
        AUTH_TYPE VARCHAR (255) NOT NULL,
        PROVISIONING_USERSTORE_DOMAIN VARCHAR (512),
        IS_LOCAL_CLAIM_DIALECT CHAR(1) DEFAULT '1',
        IS_SEND_LOCAL_SUBJECT_ID CHAR(1) DEFAULT '0',
        IS_SEND_AUTH_LIST_OF_IDPS CHAR(1) DEFAULT '0',
        IS_USE_TENANT_DOMAIN_SUBJECT CHAR(1) DEFAULT '1',
        IS_USE_USER_DOMAIN_SUBJECT CHAR(1) DEFAULT '1',
        ENABLE_AUTHORIZATION CHAR(1) DEFAULT '0',
	    SUBJECT_CLAIM_URI VARCHAR (512),
	    IS_SAAS_APP CHAR(1) DEFAULT '0',
	    IS_DUMB_MODE CHAR(1) DEFAULT '0',
        PRIMARY KEY (ID))
/
CREATE SEQUENCE SP_APP_SEQ START WITH 1 INCREMENT BY 1 NOCACHE
/
CREATE TRIGGER SP_APP_TRIG NO CASCADE
            BEFORE INSERT
            ON SP_APP
            REFERENCING NEW AS NEW
            FOR EACH ROW MODE DB2SQL
                BEGIN ATOMIC
                    SET (NEW.ID) = (NEXTVAL FOR SP_APP_SEQ);
                END
/
ALTER TABLE SP_APP ADD CONSTRAINT APPLICATION_NAME_CONSTRAINT UNIQUE(APP_NAME, TENANT_ID)
/


CREATE TABLE SP_METADATA (
            ID INTEGER NOT NULL,
            SP_ID INTEGER NOT NULL,
            NAME VARCHAR(255) NOT NULL,
            VALUE VARCHAR(255) NOT NULL,
            DISPLAY_NAME VARCHAR(255),
            TENANT_ID INTEGER DEFAULT -1,
            PRIMARY KEY (ID),
            CONSTRAINT SP_METADATA_CONSTRAINT UNIQUE (SP_ID, NAME),
            FOREIGN KEY (SP_ID) REFERENCES SP_APP(ID) ON DELETE CASCADE)
/
CREATE SEQUENCE SP_METADATA_SEQ START WITH 1 INCREMENT BY 1 NOCACHE
/
CREATE TRIGGER SP_METADATA_TRIG NO CASCADE
            BEFORE INSERT
            ON SP_METADATA
            REFERENCING NEW AS NEW
            FOR EACH ROW MODE DB2SQL
                BEGIN ATOMIC
                    SET (NEW.ID) = (NEXTVAL FOR SP_METADATA_SEQ);
                END
/

CREATE TABLE SP_INBOUND_AUTH (
            ID INTEGER NOT NULL,
            TENANT_ID INTEGER NOT NULL,
            INBOUND_AUTH_KEY VARCHAR (255),
            INBOUND_AUTH_TYPE VARCHAR (255) NOT NULL,
            INBOUND_CONFIG_TYPE VARCHAR (255) NOT NULL,
            PROP_NAME VARCHAR (255),
            PROP_VALUE VARCHAR (1024) ,
            APP_ID INTEGER NOT NULL,
            PRIMARY KEY (ID))
/
CREATE SEQUENCE SP_INBOUND_AUTH_SEQ START WITH 1 INCREMENT BY 1 NOCACHE
/
CREATE TRIGGER SP_INBOUND_AUTH_TRIG NO CASCADE
            BEFORE INSERT
            ON SP_INBOUND_AUTH
            REFERENCING NEW AS NEW
            FOR EACH ROW MODE DB2SQL
                BEGIN ATOMIC
                    SET (NEW.ID) = (NEXTVAL FOR SP_INBOUND_AUTH_SEQ);
                END
/
ALTER TABLE SP_INBOUND_AUTH ADD CONSTRAINT APPLICATION_ID_CONSTRAINT FOREIGN KEY (APP_ID) REFERENCES SP_APP (ID) ON DELETE CASCADE
/
CREATE TABLE SP_AUTH_STEP (
            ID INTEGER NOT NULL,
            TENANT_ID INTEGER NOT NULL,
            STEP_ORDER INTEGER DEFAULT 1,
            APP_ID INTEGER NOT NULL ,
            IS_SUBJECT_STEP CHAR(1) DEFAULT '0',
            IS_ATTRIBUTE_STEP CHAR(1) DEFAULT '0',
            PRIMARY KEY (ID))
/
CREATE SEQUENCE SP_AUTH_STEP_SEQ START WITH 1 INCREMENT BY 1 NOCACHE
/
CREATE TRIGGER SP_AUTH_STEP_TRIG NO CASCADE
            BEFORE INSERT
            ON SP_AUTH_STEP
            REFERENCING NEW AS NEW
            FOR EACH ROW MODE DB2SQL
                BEGIN ATOMIC
                    SET (NEW.ID) = (NEXTVAL FOR SP_AUTH_STEP_SEQ);
                END
/
ALTER TABLE SP_AUTH_STEP ADD CONSTRAINT APPLICATION_ID_CONSTRAINT_STEP FOREIGN KEY (APP_ID) REFERENCES SP_APP (ID) ON DELETE CASCADE
/
CREATE TABLE SP_FEDERATED_IDP (
            ID INTEGER NOT NULL,
            TENANT_ID INTEGER NOT NULL,
            AUTHENTICATOR_ID INTEGER NOT NULL,
            PRIMARY KEY (ID, AUTHENTICATOR_ID))
/
ALTER TABLE SP_FEDERATED_IDP ADD CONSTRAINT STEP_ID_CONSTRAINT FOREIGN KEY (ID) REFERENCES SP_AUTH_STEP (ID) ON DELETE CASCADE
/
CREATE TABLE SP_CLAIM_MAPPING (
	    	ID INTEGER NOT NULL,
	    	TENANT_ID INTEGER NOT NULL,
	    	IDP_CLAIM VARCHAR (512) NOT NULL ,
	    	SP_CLAIM VARCHAR (512) NOT NULL ,
	    	APP_ID INTEGER NOT NULL,
	    	IS_REQUESTED VARCHAR(128) DEFAULT '0',
		IS_MANDATORY VARCHAR(128) DEFAULT '0', 
	    	DEFAULT_VALUE VARCHAR(255),
	    	PRIMARY KEY (ID))
/
CREATE SEQUENCE SP_CLAIM_MAPPING_SEQ START WITH 1 INCREMENT BY 1 NOCACHE
/
CREATE TRIGGER SP_CLAIM_MAPPING_TRIG NO CASCADE
            BEFORE INSERT
            ON SP_CLAIM_MAPPING
            REFERENCING NEW AS NEW
            FOR EACH ROW MODE DB2SQL
                BEGIN ATOMIC
                    SET (NEW.ID) = (NEXTVAL FOR SP_CLAIM_MAPPING_SEQ);
                END
/
ALTER TABLE SP_CLAIM_MAPPING ADD CONSTRAINT CLAIMID_APPID_CONSTRAINT FOREIGN KEY (APP_ID) REFERENCES SP_APP (ID) ON DELETE CASCADE
/
CREATE TABLE SP_ROLE_MAPPING (
	    	ID INTEGER NOT NULL,
	    	TENANT_ID INTEGER NOT NULL,
	    	IDP_ROLE VARCHAR (255) NOT NULL ,
	    	SP_ROLE VARCHAR (255) NOT NULL ,
	    	APP_ID INTEGER NOT NULL,
	    	PRIMARY KEY (ID))
/
CREATE SEQUENCE SP_ROLE_MAPPING_SEQ START WITH 1 INCREMENT BY 1 NOCACHE
/
CREATE TRIGGER SP_ROLE_MAPPING_TRIG NO CASCADE
            BEFORE INSERT
            ON SP_ROLE_MAPPING
            REFERENCING NEW AS NEW
            FOR EACH ROW MODE DB2SQL
                BEGIN ATOMIC
                    SET (NEW.ID) = (NEXTVAL FOR SP_ROLE_MAPPING_SEQ);
                END
/
ALTER TABLE SP_ROLE_MAPPING ADD CONSTRAINT ROLEID_APPID_CONSTRAINT FOREIGN KEY (APP_ID) REFERENCES SP_APP (ID) ON DELETE CASCADE
/
CREATE TABLE SP_REQ_PATH_AUTHENTICATOR (
	    	ID INTEGER NOT NULL,
	    	TENANT_ID INTEGER NOT NULL,
	    	AUTHENTICATOR_NAME VARCHAR (255) NOT NULL ,
	    	APP_ID INTEGER NOT NULL,
	    	PRIMARY KEY (ID))
/
CREATE SEQUENCE SP_REQ_PATH_AUTH_SEQ START WITH 1 INCREMENT BY 1 NOCACHE
/
CREATE TRIGGER SP_REQ_PATH_AUTH_TRIG NO CASCADE
            BEFORE INSERT
            ON SP_REQ_PATH_AUTHENTICATOR
            REFERENCING NEW AS NEW
            FOR EACH ROW MODE DB2SQL
                BEGIN ATOMIC
                    SET (NEW.ID) = (NEXTVAL FOR SP_REQ_PATH_AUTH_SEQ);
                END
/
ALTER TABLE SP_REQ_PATH_AUTHENTICATOR ADD CONSTRAINT REQ_AUTH_APPID_CONSTRAINT FOREIGN KEY (APP_ID) REFERENCES SP_APP (ID) ON DELETE CASCADE
/
CREATE TABLE SP_PROVISIONING_CONNECTOR (
	    	ID INTEGER NOT NULL,
	    	TENANT_ID INTEGER NOT NULL,
	    	IDP_NAME VARCHAR (255) NOT NULL ,
	    	CONNECTOR_NAME VARCHAR (255) NOT NULL ,
	    	APP_ID INTEGER NOT NULL,
	    	IS_JIT_ENABLED CHAR(1) NOT NULL DEFAULT '0',
	    	BLOCKING CHAR(1) NOT NULL DEFAULT '0',
	    	RULE_ENABLED CHAR(1) NOT NULL DEFAULT '0',
	    	PRIMARY KEY (ID))
/
CREATE SEQUENCE SP_PROV_CONNECTOR_SEQ START WITH 1 INCREMENT BY 1 NOCACHE
/
CREATE TRIGGER SP_PROV_CONNECTOR_TRIG NO CASCADE
            BEFORE INSERT
            ON SP_PROVISIONING_CONNECTOR
            REFERENCING NEW AS NEW
            FOR EACH ROW MODE DB2SQL
                BEGIN ATOMIC
                    SET (NEW.ID) = (NEXTVAL FOR SP_PROV_CONNECTOR_SEQ);
                END
/
ALTER TABLE SP_PROVISIONING_CONNECTOR ADD CONSTRAINT PRO_CONNECTOR_APPID_CONSTRAINT FOREIGN KEY (APP_ID) REFERENCES SP_APP (ID) ON DELETE CASCADE
/
CREATE TABLE IDP (
			ID INTEGER NOT NULL,
			TENANT_ID INTEGER NOT NULL,
			NAME VARCHAR(254) NOT NULL,
			IS_ENABLED CHAR(1) NOT NULL DEFAULT '1',
			IS_PRIMARY CHAR(1) NOT NULL DEFAULT '0',
			HOME_REALM_ID VARCHAR(254),
			IMAGE BLOB,
			CERTIFICATE BLOB,
			ALIAS VARCHAR(254),
			INBOUND_PROV_ENABLED CHAR (1) NOT NULL DEFAULT '0',
			INBOUND_PROV_USER_STORE_ID VARCHAR(254),
 			USER_CLAIM_URI VARCHAR(254),
 			ROLE_CLAIM_URI VARCHAR(254),
 			DESCRIPTION VARCHAR (1024),
 			DEFAULT_AUTHENTICATOR_NAME VARCHAR(254),
 			DEFAULT_PRO_CONNECTOR_NAME VARCHAR(254),
 			PROVISIONING_ROLE VARCHAR(128),
 			IS_FEDERATION_HUB CHAR(1) NOT NULL DEFAULT '0',
 			IS_LOCAL_CLAIM_DIALECT CHAR(1) NOT NULL DEFAULT '0',
	                DISPLAY_NAME VARCHAR(254),
			PRIMARY KEY (ID),
			UNIQUE (TENANT_ID, NAME))
/
CREATE SEQUENCE IDP_SEQ START WITH 1 INCREMENT BY 1 NOCACHE
/
CREATE TRIGGER IDP_TRIG NO CASCADE
            BEFORE INSERT
            ON IDP
            REFERENCING NEW AS NEW
            FOR EACH ROW MODE DB2SQL
                BEGIN ATOMIC
                    SET (NEW.ID) = (NEXTVAL FOR IDP_SEQ);
                END
/
CREATE TABLE IDP_ROLE (
			ID INTEGER NOT NULL,
			IDP_ID INTEGER NOT NULL,
			TENANT_ID INTEGER NOT NULL,
			ROLE VARCHAR(254) NOT NULL,
			PRIMARY KEY (ID),
			UNIQUE (IDP_ID, ROLE),
			FOREIGN KEY (IDP_ID) REFERENCES IDP(ID) ON DELETE CASCADE)
/
CREATE SEQUENCE IDP_ROLE_SEQ START WITH 1 INCREMENT BY 1 NOCACHE
/
CREATE TRIGGER IDP_ROLE_TRIG NO CASCADE
            BEFORE INSERT
            ON IDP_ROLE
            REFERENCING NEW AS NEW
            FOR EACH ROW MODE DB2SQL
                BEGIN ATOMIC
                    SET (NEW.ID) = (NEXTVAL FOR IDP_ROLE_SEQ);
                END
/
CREATE TABLE IDP_ROLE_MAPPING (
			ID INTEGER NOT NULL,
			IDP_ROLE_ID INTEGER NOT NULL,
			TENANT_ID INTEGER NOT NULL,
			USER_STORE_ID VARCHAR (253) NOT NULL,
			LOCAL_ROLE VARCHAR(253) NOT NULL,
			PRIMARY KEY (ID),
			UNIQUE (IDP_ROLE_ID, TENANT_ID, USER_STORE_ID, LOCAL_ROLE),
			FOREIGN KEY (IDP_ROLE_ID) REFERENCES IDP_ROLE(ID) ON DELETE CASCADE)
/
CREATE SEQUENCE IDP_ROLE_MAPPING_SEQ START WITH 1 INCREMENT BY 1 NOCACHE
/
CREATE TRIGGER IDP_ROLE_MAPPING_TRIG NO CASCADE
            BEFORE INSERT
            ON IDP_ROLE_MAPPING
            REFERENCING NEW AS NEW
            FOR EACH ROW MODE DB2SQL
                BEGIN ATOMIC
                    SET (NEW.ID) = (NEXTVAL FOR IDP_ROLE_MAPPING_SEQ);
                END
/
CREATE TABLE IDP_CLAIM (
			ID INTEGER NOT NULL,
			IDP_ID INTEGER NOT NULL,
			TENANT_ID INTEGER NOT NULL,
			CLAIM VARCHAR(254) NOT NULL,
			PRIMARY KEY (ID),
			UNIQUE (IDP_ID, CLAIM),
			FOREIGN KEY (IDP_ID) REFERENCES IDP(ID) ON DELETE CASCADE)
/
CREATE SEQUENCE IDP_CLAIM_SEQ START WITH 1 INCREMENT BY 1 NOCACHE
/
CREATE TRIGGER IDP_CLAIM_TRIG NO CASCADE
            BEFORE INSERT
            ON IDP_CLAIM
            REFERENCING NEW AS NEW
            FOR EACH ROW MODE DB2SQL
                BEGIN ATOMIC
                    SET (NEW.ID) = (NEXTVAL FOR IDP_CLAIM_SEQ);
                END
/
CREATE TABLE IDP_CLAIM_MAPPING (
			ID INTEGER NOT NULL,
			IDP_CLAIM_ID INTEGER NOT NULL,
			TENANT_ID INTEGER NOT NULL,
			LOCAL_CLAIM VARCHAR(253) NOT NULL,
			DEFAULT_VALUE VARCHAR(255),
			IS_REQUESTED VARCHAR(128) DEFAULT '0',
			PRIMARY KEY (ID),
			UNIQUE (IDP_CLAIM_ID, TENANT_ID, LOCAL_CLAIM),
			FOREIGN KEY (IDP_CLAIM_ID) REFERENCES IDP_CLAIM(ID) ON DELETE CASCADE)
/
CREATE SEQUENCE IDP_CLAIM_MAPPING_SEQ START WITH 1 INCREMENT BY 1 NOCACHE
/
CREATE TRIGGER IDP_CLAIM_MAPPING_TRIG NO CASCADE
            BEFORE INSERT
            ON IDP_CLAIM_MAPPING
            REFERENCING NEW AS NEW
            FOR EACH ROW MODE DB2SQL
                BEGIN ATOMIC
                    SET (NEW.ID) = (NEXTVAL FOR IDP_CLAIM_MAPPING_SEQ);
                END
/
CREATE TABLE IDP_AUTHENTICATOR (
            ID INTEGER NOT NULL,
            TENANT_ID INTEGER NOT NULL,
            IDP_ID INTEGER NOT NULL,
            NAME VARCHAR(255) NOT NULL,
            IS_ENABLED CHAR (1) DEFAULT '1',
            DISPLAY_NAME VARCHAR(255),
            PRIMARY KEY (ID),
            UNIQUE (TENANT_ID, IDP_ID, NAME),
            FOREIGN KEY (IDP_ID) REFERENCES IDP(ID) ON DELETE CASCADE)
/
CREATE SEQUENCE IDP_AUTHENTICATOR_SEQ START WITH 1 INCREMENT BY 1 NOCACHE
/
CREATE TRIGGER IDP_AUTHENTICATOR_TRIG NO CASCADE
            BEFORE INSERT
            ON IDP_AUTHENTICATOR
            REFERENCING NEW AS NEW
            FOR EACH ROW MODE DB2SQL
                BEGIN ATOMIC
                    SET (NEW.ID) = (NEXTVAL FOR IDP_AUTHENTICATOR_SEQ);
                END
/

CREATE TABLE IDP_METADATA (
            ID INTEGER NOT NULL,
            IDP_ID INTEGER NOT NULL,
            NAME VARCHAR(255) NOT NULL,
            VALUE VARCHAR(255),
            DISPLAY_NAME VARCHAR(255),
            TENANT_ID INTEGER DEFAULT -1,
            PRIMARY KEY (ID),
            CONSTRAINT IDP_METADATA_CONSTRAINT UNIQUE (IDP_ID, NAME),
            FOREIGN KEY (IDP_ID) REFERENCES IDP(ID) ON DELETE CASCADE)
/

CREATE SEQUENCE IDP_METADATA_SEQ START WITH 1 INCREMENT BY 1 NOCACHE
/
CREATE TRIGGER IDP_METADATA_TRIG NO CASCADE
            BEFORE INSERT
            ON IDP_METADATA
            REFERENCING NEW AS NEW
            FOR EACH ROW MODE DB2SQL
                BEGIN ATOMIC
                    SET (NEW.ID) = (NEXTVAL FOR IDP_METADATA_SEQ);
                END
/
CREATE TABLE IDP_AUTHENTICATOR_PROPERTY (
            ID INTEGER NOT NULL,
            TENANT_ID INTEGER NOT NULL,
            AUTHENTICATOR_ID INTEGER NOT NULL,
            PROPERTY_KEY VARCHAR(255) NOT NULL,
            PROPERTY_VALUE VARCHAR(2047),
            IS_SECRET CHAR (1) DEFAULT '0',
            PRIMARY KEY (ID),
            UNIQUE (TENANT_ID, AUTHENTICATOR_ID, PROPERTY_KEY),
            FOREIGN KEY (AUTHENTICATOR_ID) REFERENCES IDP_AUTHENTICATOR(ID) ON DELETE CASCADE)
/
CREATE SEQUENCE IDP_AUTHENTICATOR_PROP_SEQ START WITH 1 INCREMENT BY 1 NOCACHE
/
CREATE TRIGGER IDP_AUTHENTICATOR_PROP_TRIG NO CASCADE
            BEFORE INSERT
            ON IDP_AUTHENTICATOR_PROPERTY
            REFERENCING NEW AS NEW
            FOR EACH ROW MODE DB2SQL
                BEGIN ATOMIC
                    SET (NEW.ID) = (NEXTVAL FOR IDP_AUTHENTICATOR_PROP_SEQ);
                END
/

CREATE TABLE IDP_PROVISIONING_CONFIG (
            ID INTEGER NOT NULL,
            TENANT_ID INTEGER NOT NULL,
            IDP_ID INTEGER NOT NULL,
            PROVISIONING_CONNECTOR_TYPE VARCHAR(255) NOT NULL,
            IS_ENABLED CHAR (1) DEFAULT '0',
            IS_BLOCKING CHAR (1) DEFAULT '0',
            IS_RULES_ENABLED CHAR (1) DEFAULT '0',
            PRIMARY KEY (ID),
            UNIQUE (TENANT_ID, IDP_ID, PROVISIONING_CONNECTOR_TYPE),
            FOREIGN KEY (IDP_ID) REFERENCES IDP(ID) ON DELETE CASCADE)
/
CREATE SEQUENCE IDP_PROV_CONFIG_SEQ START WITH 1 INCREMENT BY 1 NOCACHE
/
CREATE TRIGGER IDP_PROV_CONFIG_TRIG NO CASCADE
            BEFORE INSERT
            ON IDP_PROVISIONING_CONFIG
            REFERENCING NEW AS NEW
            FOR EACH ROW MODE DB2SQL
                BEGIN ATOMIC
                    SET (NEW.ID) = (NEXTVAL FOR IDP_PROV_CONFIG_SEQ);
                END
/
CREATE TABLE IDP_PROV_CONFIG_PROPERTY (
            ID INTEGER NOT NULL,
            TENANT_ID INTEGER NOT NULL,
            PROVISIONING_CONFIG_ID INTEGER NOT NULL,
            PROPERTY_KEY VARCHAR(255) NOT NULL,
            PROPERTY_VALUE VARCHAR(2048),
            PROPERTY_BLOB_VALUE BLOB,
            PROPERTY_TYPE CHAR(32) NOT NULL,
            IS_SECRET CHAR (1) DEFAULT '0',
            PRIMARY KEY (ID),
            UNIQUE (TENANT_ID, PROVISIONING_CONFIG_ID, PROPERTY_KEY),
            FOREIGN KEY (PROVISIONING_CONFIG_ID) REFERENCES IDP_PROVISIONING_CONFIG(ID) ON DELETE CASCADE)
/
CREATE SEQUENCE IDP_PROV_CONFIG_PROP_SEQ START WITH 1 INCREMENT BY 1 NOCACHE
/
CREATE TRIGGER IDP_PROV_CONFIG_PROP_TRIG NO CASCADE
            BEFORE INSERT
            ON IDP_PROV_CONFIG_PROPERTY
            REFERENCING NEW AS NEW
            FOR EACH ROW MODE DB2SQL
                BEGIN ATOMIC
                    SET (NEW.ID) = (NEXTVAL FOR IDP_PROV_CONFIG_PROP_SEQ);
                END
/
CREATE TABLE IDP_PROVISIONING_ENTITY (
            ID INTEGER NOT NULL,
            PROVISIONING_CONFIG_ID INTEGER NOT NULL,
            ENTITY_TYPE VARCHAR(255) NOT NULL,
            ENTITY_LOCAL_USERSTORE VARCHAR(255) NOT NULL,
            ENTITY_NAME VARCHAR(255) NOT NULL,
            ENTITY_VALUE VARCHAR(255) NOT NULL,
            TENANT_ID INTEGER NOT NULL,
            ENTITY_LOCAL_ID VARCHAR(255),
            PRIMARY KEY (ID),
            UNIQUE (ENTITY_TYPE, TENANT_ID, ENTITY_LOCAL_USERSTORE, ENTITY_NAME, PROVISIONING_CONFIG_ID),
            UNIQUE (PROVISIONING_CONFIG_ID, ENTITY_TYPE, ENTITY_VALUE),
            FOREIGN KEY (PROVISIONING_CONFIG_ID) REFERENCES IDP_PROVISIONING_CONFIG(ID) ON DELETE CASCADE)
/
CREATE SEQUENCE IDP_PROV_ENTITY_SEQ START WITH 1 INCREMENT BY 1 NOCACHE
/
CREATE TRIGGER IDP_PROV_ENTITY_TRIG NO CASCADE
            BEFORE INSERT
            ON IDP_PROVISIONING_ENTITY
            REFERENCING NEW AS NEW
            FOR EACH ROW MODE DB2SQL
                BEGIN ATOMIC
                    SET (NEW.ID) = (NEXTVAL FOR IDP_PROV_ENTITY_SEQ);
                END
/
CREATE TABLE IDP_LOCAL_CLAIM (
            ID INTEGER NOT NULL,
            TENANT_ID INTEGER NOT NULL,
            IDP_ID INTEGER NOT NULL,
            CLAIM_URI VARCHAR(255) NOT NULL,
            DEFAULT_VALUE VARCHAR(255),
       	    IS_REQUESTED VARCHAR(128) DEFAULT '0',
            PRIMARY KEY (ID),
            UNIQUE (TENANT_ID, IDP_ID, CLAIM_URI),
            FOREIGN KEY (IDP_ID) REFERENCES IDP(ID) ON DELETE CASCADE)
/
CREATE SEQUENCE IDP_LOCAL_CLAIM_SEQ START WITH 1 INCREMENT BY 1 NOCACHE
/
CREATE TRIGGER IDP_LOCAL_CLAIM_TRIG NO CASCADE
            BEFORE INSERT
            ON IDP_LOCAL_CLAIM
            REFERENCING NEW AS NEW
            FOR EACH ROW MODE DB2SQL
                BEGIN ATOMIC
                    SET (NEW.ID) = (NEXTVAL FOR IDP_LOCAL_CLAIM_SEQ);
                END
/
CREATE TABLE IDN_ASSOCIATED_ID (
            ID INTEGER NOT NULL,
            IDP_USER_ID VARCHAR(255) NOT NULL,
            TENANT_ID INTEGER NOT NULL DEFAULT -1234,
            IDP_ID INTEGER NOT NULL,
            DOMAIN_NAME VARCHAR(255) NOT NULL,
            USER_NAME VARCHAR(255) NOT NULL,
            PRIMARY KEY (ID),
            UNIQUE(IDP_USER_ID, TENANT_ID, IDP_ID),
            FOREIGN KEY (IDP_ID) REFERENCES IDP(ID) ON DELETE CASCADE)
/

CREATE SEQUENCE IDN_ASSOCIATED_ID_SEQ START WITH 1 INCREMENT BY 1 NOCACHE
/
CREATE TRIGGER IDN_ASSOCIATED_ID_TRIG NO CASCADE
            BEFORE INSERT
            ON IDN_ASSOCIATED_ID
	    REFERENCING NEW AS NEW
            FOR EACH ROW MODE DB2SQL
                BEGIN ATOMIC
                    SET (NEW.ID) = (NEXTVAL FOR IDN_ASSOCIATED_ID_SEQ);
                END
/
CREATE TABLE IDN_USER_ACCOUNT_ASSOCIATION (
            ASSOCIATION_KEY VARCHAR(255) NOT NULL,
            TENANT_ID INTEGER NOT NULL,
            DOMAIN_NAME VARCHAR(255) NOT NULL,
            USER_NAME VARCHAR(255) NOT NULL,
            PRIMARY KEY (TENANT_ID, DOMAIN_NAME, USER_NAME))
/
CREATE TABLE FIDO_DEVICE_STORE (
        TENANT_ID INTEGER NOT NULL,
        DOMAIN_NAME VARCHAR(255) NOT NULL,
        USER_NAME VARCHAR(45) NOT NULL,
        TIME_REGISTERED TIMESTAMP,
        KEY_HANDLE VARCHAR(200) NOT NULL,
        DEVICE_DATA VARCHAR(2048) NOT NULL,
        PRIMARY KEY (TENANT_ID, DOMAIN_NAME, USER_NAME, KEY_HANDLE))
/

CREATE TABLE WF_REQUEST (
    UUID VARCHAR (45) NOT NULL,
    CREATED_BY VARCHAR (255),
    TENANT_ID INTEGER NOT NULL DEFAULT -1,
    OPERATION_TYPE VARCHAR (50),
    CREATED_AT TIMESTAMP,
    UPDATED_AT TIMESTAMP,
    STATUS VARCHAR (30),
    REQUEST BLOB,
    PRIMARY KEY (UUID))
/

CREATE TABLE WF_BPS_PROFILE (
    PROFILE_NAME VARCHAR(45) NOT NULL,
    HOST_URL_MANAGER VARCHAR(255),
    HOST_URL_WORKER VARCHAR(255),
    USERNAME VARCHAR(45),
    PASSWORD VARCHAR(1023),
    CALLBACK_HOST VARCHAR (45),
    TENANT_ID INTEGER NOT NULL DEFAULT -1,
    PRIMARY KEY (PROFILE_NAME, TENANT_ID))
/

CREATE TABLE WF_WORKFLOW(
    ID VARCHAR (45) NOT NULL,
    WF_NAME VARCHAR (45),
    DESCRIPTION VARCHAR (255),
    TEMPLATE_ID VARCHAR (45),
    IMPL_ID VARCHAR (45),
    TENANT_ID INTEGER NOT NULL DEFAULT -1,
    PRIMARY KEY (ID))
/

CREATE TABLE WF_WORKFLOW_ASSOCIATION(
    ID INTEGER NOT NULL,
    ASSOC_NAME VARCHAR (45),
    EVENT_ID VARCHAR(45),
    ASSOC_CONDITION VARCHAR (2000),
    WORKFLOW_ID VARCHAR (45),
    IS_ENABLED CHAR (1) DEFAULT '1',
    TENANT_ID INTEGER DEFAULT -1,
    PRIMARY KEY(ID),
    FOREIGN KEY (WORKFLOW_ID) REFERENCES WF_WORKFLOW(ID)ON DELETE CASCADE)
/

CREATE SEQUENCE WF_WORKFLOW_ASSOCIATION_SEQ START WITH 1 INCREMENT BY 1 NOCACHE
/

CREATE TRIGGER WF_WORKFLOW_ASSOCIATION_TRIG NO CASCADE
    BEFORE INSERT
    ON WF_WORKFLOW_ASSOCIATION
    REFERENCING NEW AS NEW
    FOR EACH ROW MODE DB2SQL
      BEGIN ATOMIC
        SET (NEW.ID) = (NEXTVAL FOR WF_WORKFLOW_ASSOCIATION_SEQ);
      END
/

CREATE TABLE WF_WORKFLOW_CONFIG_PARAM(
    WORKFLOW_ID VARCHAR (45) NOT NULL,
    PARAM_NAME VARCHAR (45) NOT NULL,
    PARAM_VALUE VARCHAR (1000),
    PARAM_QNAME VARCHAR (45) NOT NULL,
    PARAM_HOLDER VARCHAR (45) NOT NULL,
    TENANT_ID INTEGER DEFAULT -1,
    PRIMARY KEY (WORKFLOW_ID, PARAM_NAME, PARAM_QNAME, PARAM_HOLDER),
    FOREIGN KEY (WORKFLOW_ID) REFERENCES WF_WORKFLOW(ID)ON DELETE CASCADE)
/

CREATE TABLE WF_REQUEST_ENTITY_RELATIONSHIP(
  REQUEST_ID VARCHAR (45) NOT NULL,
  ENTITY_NAME VARCHAR (255) NOT NULL,
  ENTITY_TYPE VARCHAR (50) NOT NULL,
  TENANT_ID INTEGER NOT NULL DEFAULT -1,
  PRIMARY KEY(REQUEST_ID, ENTITY_NAME, ENTITY_TYPE, TENANT_ID),
  FOREIGN KEY (REQUEST_ID) REFERENCES WF_REQUEST(UUID)ON DELETE CASCADE)
/

CREATE TABLE WF_WORKFLOW_REQUEST_RELATION(
  RELATIONSHIP_ID VARCHAR (45) NOT NULL,
  WORKFLOW_ID VARCHAR (45),
  REQUEST_ID VARCHAR (45),
  UPDATED_AT TIMESTAMP,
  STATUS VARCHAR (30),
  TENANT_ID INTEGER DEFAULT -1,
  PRIMARY KEY (RELATIONSHIP_ID),
  FOREIGN KEY (WORKFLOW_ID) REFERENCES WF_WORKFLOW(ID)ON DELETE CASCADE,
  FOREIGN KEY (REQUEST_ID) REFERENCES WF_REQUEST(UUID)ON DELETE CASCADE)
/

CREATE TABLE IDN_RECOVERY_DATA (
  USER_NAME VARCHAR(255) NOT NULL,
  USER_DOMAIN VARCHAR(127) NOT NULL,
  TENANT_ID INTEGER DEFAULT -1 NOT NULL,
  CODE VARCHAR(255) NOT NULL,
  SCENARIO VARCHAR(255) NOT NULL,
  STEP VARCHAR(127) NOT NULL,
  TIME_CREATED TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  REMAINING_SETS VARCHAR(2500),
  PRIMARY KEY(USER_NAME, USER_DOMAIN, TENANT_ID, SCENARIO,STEP),
  UNIQUE(CODE))
/

CREATE TABLE IDN_PASSWORD_HISTORY_DATA (
  ID INTEGER NOT NULL,
  USER_NAME   VARCHAR(255) NOT NULL,
  USER_DOMAIN VARCHAR(127) NOT NULL,
  TENANT_ID   INTEGER DEFAULT -1 NOT NULL,
  SALT_VALUE  VARCHAR(255) NOT NULL,
  HASH        VARCHAR(255) NOT NULL,
  TIME_CREATED TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (ID),
  UNIQUE (USER_NAME,USER_DOMAIN,TENANT_ID,SALT_VALUE,HASH)
  )
/

CREATE SEQUENCE IDN_PASSWORD_HISTORY_DATA_SEQ START WITH 1 INCREMENT BY 1 NOCACHE
/

CREATE TRIGGER IDN_PASSWORD_HISTORY_DATA NO CASCADE
    BEFORE INSERT
    ON IDN_PASSWORD_HISTORY_DATA
    REFERENCING NEW AS NEW
    FOR EACH ROW MODE DB2SQL
      BEGIN ATOMIC
        SET (NEW.ID) = (NEXTVAL FOR IDN_PASSWORD_HISTORY_DATA_SEQ);
      END
/

CREATE TABLE IDN_CLAIM_DIALECT (
  ID INTEGER NOT NULL,
  DIALECT_URI VARCHAR (255) NOT NULL,
  TENANT_ID INTEGER NOT NULL,
  PRIMARY KEY (ID),
  CONSTRAINT DIALECT_URI_CONSTRAINT UNIQUE (DIALECT_URI, TENANT_ID))
/
CREATE SEQUENCE IDN_CLAIM_DIALECT_SEQ START WITH 1 INCREMENT BY 1 NOCACHE
/
CREATE TRIGGER IDN_CLAIM_DIALECT_TRIG NO CASCADE
            BEFORE INSERT
            ON IDN_CLAIM_DIALECT
            REFERENCING NEW AS NEW
            FOR EACH ROW MODE DB2SQL
                BEGIN ATOMIC
                    SET (NEW.ID) = (NEXTVAL FOR IDN_CLAIM_DIALECT_SEQ);
                END
/

CREATE TABLE IDN_CLAIM (
  ID INTEGER NOT NULL,
  DIALECT_ID INTEGER NOT NULL,
  CLAIM_URI VARCHAR (255) NOT NULL,
  TENANT_ID INTEGER NOT NULL,
  PRIMARY KEY (ID),
  FOREIGN KEY (DIALECT_ID) REFERENCES IDN_CLAIM_DIALECT(ID) ON DELETE CASCADE,
  CONSTRAINT CLAIM_URI_CONSTRAINT UNIQUE (DIALECT_ID, CLAIM_URI, TENANT_ID))
/
CREATE SEQUENCE IDN_CLAIM_SEQ START WITH 1 INCREMENT BY 1 NOCACHE
/
CREATE TRIGGER IDN_CLAIM_TRIG NO CASCADE
            BEFORE INSERT
            ON IDN_CLAIM
            REFERENCING NEW AS NEW
            FOR EACH ROW MODE DB2SQL
                BEGIN ATOMIC
                    SET (NEW.ID) = (NEXTVAL FOR IDN_CLAIM_SEQ);
                END
/

CREATE TABLE IDN_CLAIM_MAPPED_ATTRIBUTE (
  ID INTEGER NOT NULL,
  LOCAL_CLAIM_ID INTEGER NOT NULL,
  USER_STORE_DOMAIN_NAME VARCHAR (255) NOT NULL,
  ATTRIBUTE_NAME VARCHAR (255) NOT NULL,
  TENANT_ID INTEGER NOT NULL,
  PRIMARY KEY (ID),
  FOREIGN KEY (LOCAL_CLAIM_ID) REFERENCES IDN_CLAIM(ID) ON DELETE CASCADE,
  CONSTRAINT USER_STORE_DOMAIN_CONSTRAINT UNIQUE (LOCAL_CLAIM_ID, USER_STORE_DOMAIN_NAME, TENANT_ID))
/
CREATE SEQUENCE IDN_CLAIM_MAPPED_ATTRIBUTE_SEQ START WITH 1 INCREMENT BY 1 NOCACHE
/
CREATE TRIGGER IDN_CLAIM_MAPPED_ATTR_TRIG NO CASCADE
            BEFORE INSERT
            ON IDN_CLAIM_MAPPED_ATTRIBUTE
            REFERENCING NEW AS NEW
            FOR EACH ROW MODE DB2SQL
                BEGIN ATOMIC
                    SET (NEW.ID) = (NEXTVAL FOR IDN_CLAIM_MAPPED_ATTRIBUTE_SEQ);
                END
/

CREATE TABLE IDN_CLAIM_PROPERTY (
  ID INTEGER NOT NULL,
  LOCAL_CLAIM_ID INTEGER NOT NULL,
  PROPERTY_NAME VARCHAR (255) NOT NULL,
  PROPERTY_VALUE VARCHAR (255) NOT NULL,
  TENANT_ID INTEGER NOT NULL,
  PRIMARY KEY (ID),
  FOREIGN KEY (LOCAL_CLAIM_ID) REFERENCES IDN_CLAIM(ID) ON DELETE CASCADE,
  CONSTRAINT PROPERTY_NAME_CONSTRAINT UNIQUE (LOCAL_CLAIM_ID, PROPERTY_NAME, TENANT_ID))
/
CREATE SEQUENCE IDN_CLAIM_PROPERTY_SEQ START WITH 1 INCREMENT BY 1 NOCACHE
/
CREATE TRIGGER IDN_CLAIM_PROPERTY_TRIG NO CASCADE
            BEFORE INSERT
            ON IDN_CLAIM_PROPERTY
            REFERENCING NEW AS NEW
            FOR EACH ROW MODE DB2SQL
                BEGIN ATOMIC
                    SET (NEW.ID) = (NEXTVAL FOR IDN_CLAIM_PROPERTY_SEQ);
                END
/

CREATE TABLE IDN_CLAIM_MAPPING (
  ID INTEGER NOT NULL,
  EXT_CLAIM_ID INTEGER NOT NULL,
  MAPPED_LOCAL_CLAIM_ID INTEGER NOT NULL,
  TENANT_ID INTEGER NOT NULL,
  PRIMARY KEY (ID),
  FOREIGN KEY (EXT_CLAIM_ID) REFERENCES IDN_CLAIM(ID) ON DELETE CASCADE,
  FOREIGN KEY (MAPPED_LOCAL_CLAIM_ID) REFERENCES IDN_CLAIM(ID) ON DELETE CASCADE,
  CONSTRAINT EXT_TO_LOC_MAPPING_CONSTRN UNIQUE (EXT_CLAIM_ID, TENANT_ID))
/
CREATE SEQUENCE IDN_CLAIM_MAPPING_SEQ START WITH 1 INCREMENT BY 1 NOCACHE
/
CREATE TRIGGER IDN_CLAIM_MAPPING_TRIG NO CASCADE
            BEFORE INSERT
            ON IDN_CLAIM_MAPPING
            REFERENCING NEW AS NEW
            FOR EACH ROW MODE DB2SQL
                BEGIN ATOMIC
                    SET (NEW.ID) = (NEXTVAL FOR IDN_CLAIM_MAPPING_SEQ);
                END
/

CREATE TABLE IDN_SAML2_ASSERTION_STORE (
  ID INTEGER NOT NULL,
  SAML2_ID  VARCHAR(255) ,
  SAML2_ISSUER  VARCHAR(255) ,
  SAML2_SUBJECT  VARCHAR(255) ,
  SAML2_SESSION_INDEX  VARCHAR(255) ,
  SAML2_AUTHN_CONTEXT_CLASS_REF  VARCHAR(255) ,
  SAML2_ASSERTION  VARCHAR(4096) ,
  PRIMARY KEY (ID))
/
CREATE SEQUENCE IDN_SAML2_ASSERTION_STORE_SEQ START WITH 1 INCREMENT BY 1 NOCACHE
/
CREATE TRIGGER IDN_SAML2_ASSERTION_STORE_TRIG NO CASCADE
            BEFORE INSERT
            ON IDN_SAML2_ASSERTION_STORE
            REFERENCING NEW AS NEW
            FOR EACH ROW MODE DB2SQL
                BEGIN ATOMIC
                    SET (NEW.ID) = (NEXTVAL FOR IDN_SAML2_ASSERTION_STORE_SEQ);
                END
/

CREATE TABLE IDN_OIDC_JTI (
  JWT_ID VARCHAR(255),
  EXP_TIME TIMESTAMP DEFAULT 0,
  TIME_CREATED TIMESTAMP DEFAULT 0,
  PRIMARY KEY (JWT_ID))
/

