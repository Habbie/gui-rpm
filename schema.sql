create table domains (
 id              SERIAL PRIMARY KEY,
 name            VARCHAR(255) NOT NULL,
 master          VARCHAR(128) DEFAULT NULL,
 last_check      INT DEFAULT NULL,
 type            VARCHAR(6) NOT NULL,
 notified_serial INT DEFAULT NULL,
 account         VARCHAR(40) DEFAULT NULL,
 CONSTRAINT c_lowercase_name CHECK (((name)::text = lower((name)::text)))
);
CREATE UNIQUE INDEX name_index ON domains(name);

CREATE TABLE records (
        id              SERIAL PRIMARY KEY,
        domain_id       INT DEFAULT NULL,
        name            VARCHAR(255) DEFAULT NULL,
        type            VARCHAR(10) DEFAULT NULL,
        content         VARCHAR(65535) DEFAULT NULL,
        ttl             INT DEFAULT NULL,
        prio            INT DEFAULT NULL,
        change_date     INT DEFAULT NULL,
        disabled        BOOL DEFAULT NULL,
        CONSTRAINT domain_exists
        FOREIGN KEY(domain_id) REFERENCES domains(id)
        ON DELETE CASCADE,
        CONSTRAINT c_lowercase_name CHECK (((name)::text = lower((name)::text)))
);

CREATE INDEX rec_name_index ON records(name);
CREATE INDEX nametype_index ON records(name,type);
CREATE INDEX domain_id ON records(domain_id);

create table supermasters (
          ip INET NOT NULL,
          nameserver VARCHAR(255) NOT NULL,
          account VARCHAR(40) DEFAULT NULL,
          PRIMARY KEY (ip, nameserver)
);
alter table records add ordername   VARCHAR(255);
alter table records add auth bool;
create index recordorder on records (domain_id, ordername text_pattern_ops);

create table domainmetadata (
 id         SERIAL PRIMARY KEY,
 domain_id  INT REFERENCES domains(id) ON DELETE CASCADE,
 kind       VARCHAR(16),
 content    TEXT
);

create index domainidmetaindex on domainmetadata(domain_id);


create table cryptokeys (
 id         SERIAL PRIMARY KEY,
 domain_id  INT REFERENCES domains(id) ON DELETE CASCADE,
 flags      INT NOT NULL,
 active     BOOL,
 content    TEXT
);
create index domainidindex on cryptokeys(domain_id);


create table tsigkeys (
 id         SERIAL PRIMARY KEY,
 name       VARCHAR(255),
 algorithm  VARCHAR(50),
 secret     VARCHAR(255),
 constraint c_lowercase_name check (((name)::text = lower((name)::text)))
);

create unique index namealgoindex on tsigkeys(name, algorithm);

alter table records alter column type type VARCHAR(10);
