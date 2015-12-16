--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

--
-- Name: editions_generate_tsvector(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION editions_generate_tsvector() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
        BEGIN
          UPDATE guides SET tsv =
              setweight(to_tsvector('pg_catalog.english', coalesce(guides.slug,'')), 'A') ||
              setweight(to_tsvector('pg_catalog.english', coalesce(new.title,'')), 'B')
            WHERE guides.id = new.guide_id
            ;
          return new;
        END
      $$;


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: approvals; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE approvals (
    id integer NOT NULL,
    user_id integer,
    edition_id integer
);


--
-- Name: approvals_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE approvals_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: approvals_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE approvals_id_seq OWNED BY approvals.id;


--
-- Name: comments; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE comments (
    id integer NOT NULL,
    comment text,
    commentable_id integer,
    commentable_type character varying,
    user_id integer,
    role character varying DEFAULT 'comments'::character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: comments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE comments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE comments_id_seq OWNED BY comments.id;


--
-- Name: content_owners; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE content_owners (
    id integer NOT NULL,
    title character varying NOT NULL,
    href character varying NOT NULL
);


--
-- Name: content_owners_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE content_owners_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: content_owners_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE content_owners_id_seq OWNED BY content_owners.id;


--
-- Name: editions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE editions (
    id integer NOT NULL,
    guide_id integer,
    user_id integer,
    title text,
    description text,
    body text,
    update_type character varying,
    phase text DEFAULT 'alpha'::text,
    related_discussion_href text,
    related_discussion_title text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    state text,
    change_note text,
    content_owner_id integer NOT NULL,
    change_summary text
);


--
-- Name: editions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE editions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: editions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE editions_id_seq OWNED BY editions.id;


--
-- Name: guides; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE guides (
    id integer NOT NULL,
    slug character varying,
    content_id character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    tsv tsvector
);


--
-- Name: guides_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE guides_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: guides_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE guides_id_seq OWNED BY guides.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying NOT NULL
);


--
-- Name: slug_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE slug_migrations (
    id integer NOT NULL,
    slug character varying,
    completed boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    guide_id integer,
    content_id character varying NOT NULL
);


--
-- Name: slug_migrations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE slug_migrations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: slug_migrations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE slug_migrations_id_seq OWNED BY slug_migrations.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE users (
    id integer NOT NULL,
    uid text,
    name text,
    email text,
    organisation_slug text,
    organisation_content_id text,
    remotely_signed_out boolean DEFAULT false,
    disabled boolean DEFAULT false,
    permissions text[],
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY approvals ALTER COLUMN id SET DEFAULT nextval('approvals_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY comments ALTER COLUMN id SET DEFAULT nextval('comments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY content_owners ALTER COLUMN id SET DEFAULT nextval('content_owners_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY editions ALTER COLUMN id SET DEFAULT nextval('editions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY guides ALTER COLUMN id SET DEFAULT nextval('guides_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY slug_migrations ALTER COLUMN id SET DEFAULT nextval('slug_migrations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: approvals_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY approvals
    ADD CONSTRAINT approvals_pkey PRIMARY KEY (id);


--
-- Name: comments_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY comments
    ADD CONSTRAINT comments_pkey PRIMARY KEY (id);


--
-- Name: content_owners_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY content_owners
    ADD CONSTRAINT content_owners_pkey PRIMARY KEY (id);


--
-- Name: editions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY editions
    ADD CONSTRAINT editions_pkey PRIMARY KEY (id);


--
-- Name: guides_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY guides
    ADD CONSTRAINT guides_pkey PRIMARY KEY (id);


--
-- Name: slug_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY slug_migrations
    ADD CONSTRAINT slug_migrations_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: guides_tsv_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX guides_tsv_idx ON guides USING gin (tsv);


--
-- Name: index_comments_on_commentable_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_comments_on_commentable_id ON comments USING btree (commentable_id);


--
-- Name: index_comments_on_commentable_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_comments_on_commentable_type ON comments USING btree (commentable_type);


--
-- Name: index_comments_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_comments_on_user_id ON comments USING btree (user_id);


--
-- Name: index_slug_migrations_on_slug; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_slug_migrations_on_slug ON slug_migrations USING btree (slug);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_users_on_email ON users USING btree (email);


--
-- Name: index_users_on_organisation_content_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_users_on_organisation_content_id ON users USING btree (organisation_content_id);


--
-- Name: index_users_on_uid; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_users_on_uid ON users USING btree (uid);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- Name: tsvector_editions_upsert_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER tsvector_editions_upsert_trigger AFTER INSERT OR UPDATE ON editions FOR EACH ROW EXECUTE PROCEDURE editions_generate_tsvector();


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user",public;

INSERT INTO schema_migrations (version) VALUES ('20151009125935');

INSERT INTO schema_migrations (version) VALUES ('20151012105912');

INSERT INTO schema_migrations (version) VALUES ('20151013102859');

INSERT INTO schema_migrations (version) VALUES ('20151013111221');

INSERT INTO schema_migrations (version) VALUES ('20151013114232');

INSERT INTO schema_migrations (version) VALUES ('20151013135813');

INSERT INTO schema_migrations (version) VALUES ('20151027095557');

INSERT INTO schema_migrations (version) VALUES ('20151102145752');

INSERT INTO schema_migrations (version) VALUES ('20151103120443');

INSERT INTO schema_migrations (version) VALUES ('20151105142126');

INSERT INTO schema_migrations (version) VALUES ('20151109142125');

INSERT INTO schema_migrations (version) VALUES ('20151110123937');

INSERT INTO schema_migrations (version) VALUES ('20151110135512');

INSERT INTO schema_migrations (version) VALUES ('20151110162230');

INSERT INTO schema_migrations (version) VALUES ('20151112133846');

INSERT INTO schema_migrations (version) VALUES ('20151116113920');

INSERT INTO schema_migrations (version) VALUES ('20151119131239');

INSERT INTO schema_migrations (version) VALUES ('20151211164627');

INSERT INTO schema_migrations (version) VALUES ('20151216125006');

