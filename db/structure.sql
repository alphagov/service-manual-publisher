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
-- Name: editions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE editions (
    id integer NOT NULL,
    guide_id integer,
    author_id integer,
    title text,
    description text,
    body text,
    update_type character varying,
    phase text DEFAULT 'beta'::text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    state text,
    change_note text,
    content_owner_id integer,
    version integer,
    created_by_id integer
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
    tsv tsvector,
    type character varying
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
-- Name: redirects; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE redirects (
    id integer NOT NULL,
    content_id text NOT NULL,
    old_path text NOT NULL,
    new_path text NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: redirects_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE redirects_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: redirects_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE redirects_id_seq OWNED BY redirects.id;


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
    content_id character varying NOT NULL,
    redirect_to character varying
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
-- Name: topic_section_guides; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE topic_section_guides (
    id integer NOT NULL,
    topic_section_id integer NOT NULL,
    guide_id integer NOT NULL,
    "position" integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: topic_section_guides_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE topic_section_guides_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: topic_section_guides_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE topic_section_guides_id_seq OWNED BY topic_section_guides.id;


--
-- Name: topic_sections; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE topic_sections (
    id integer NOT NULL,
    topic_id integer NOT NULL,
    title character varying,
    description character varying,
    "position" integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: topic_sections_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE topic_sections_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: topic_sections_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE topic_sections_id_seq OWNED BY topic_sections.id;


--
-- Name: topics; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE topics (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    path character varying NOT NULL,
    title character varying NOT NULL,
    description character varying NOT NULL,
    content_id character varying,
    visually_collapsed boolean DEFAULT false,
    email_alert_signup_content_id character varying,
    include_on_homepage boolean DEFAULT true
);


--
-- Name: topics_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE topics_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: topics_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE topics_id_seq OWNED BY topics.id;


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

ALTER TABLE ONLY editions ALTER COLUMN id SET DEFAULT nextval('editions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY guides ALTER COLUMN id SET DEFAULT nextval('guides_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY redirects ALTER COLUMN id SET DEFAULT nextval('redirects_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY slug_migrations ALTER COLUMN id SET DEFAULT nextval('slug_migrations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY topic_section_guides ALTER COLUMN id SET DEFAULT nextval('topic_section_guides_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY topic_sections ALTER COLUMN id SET DEFAULT nextval('topic_sections_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY topics ALTER COLUMN id SET DEFAULT nextval('topics_id_seq'::regclass);


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
-- Name: redirects_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY redirects
    ADD CONSTRAINT redirects_pkey PRIMARY KEY (id);


--
-- Name: slug_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY slug_migrations
    ADD CONSTRAINT slug_migrations_pkey PRIMARY KEY (id);


--
-- Name: topic_section_guides_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY topic_section_guides
    ADD CONSTRAINT topic_section_guides_pkey PRIMARY KEY (id);


--
-- Name: topic_sections_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY topic_sections
    ADD CONSTRAINT topic_sections_pkey PRIMARY KEY (id);


--
-- Name: topics_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY topics
    ADD CONSTRAINT topics_pkey PRIMARY KEY (id);


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
-- Name: index_approvals_on_edition_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_approvals_on_edition_id ON approvals USING btree (edition_id);


--
-- Name: index_approvals_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_approvals_on_user_id ON approvals USING btree (user_id);


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
-- Name: index_editions_on_author_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_editions_on_author_id ON editions USING btree (author_id);


--
-- Name: index_editions_on_content_owner_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_editions_on_content_owner_id ON editions USING btree (content_owner_id);


--
-- Name: index_editions_on_guide_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_editions_on_guide_id ON editions USING btree (guide_id);


--
-- Name: index_guides_on_content_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_guides_on_content_id ON guides USING btree (content_id);


--
-- Name: index_redirects_on_content_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_redirects_on_content_id ON redirects USING btree (content_id);


--
-- Name: index_slug_migrations_on_content_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_slug_migrations_on_content_id ON slug_migrations USING btree (content_id);


--
-- Name: index_slug_migrations_on_slug; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_slug_migrations_on_slug ON slug_migrations USING btree (slug);


--
-- Name: index_topic_section_guides_on_guide_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_topic_section_guides_on_guide_id ON topic_section_guides USING btree (guide_id);


--
-- Name: index_topic_section_guides_on_topic_section_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_topic_section_guides_on_topic_section_id ON topic_section_guides USING btree (topic_section_id);


--
-- Name: index_topic_sections_on_topic_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_topic_sections_on_topic_id ON topic_sections USING btree (topic_id);


--
-- Name: index_topics_on_content_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_topics_on_content_id ON topics USING btree (content_id);


--
-- Name: index_topics_on_email_alert_signup_content_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_topics_on_email_alert_signup_content_id ON topics USING btree (email_alert_signup_content_id);


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

INSERT INTO schema_migrations (version) VALUES ('20160107144631');

INSERT INTO schema_migrations (version) VALUES ('20160113110500');

INSERT INTO schema_migrations (version) VALUES ('20160115104456');

INSERT INTO schema_migrations (version) VALUES ('20160120143132');

INSERT INTO schema_migrations (version) VALUES ('20160209114249');

INSERT INTO schema_migrations (version) VALUES ('20160223095349');

INSERT INTO schema_migrations (version) VALUES ('20160223101735');

INSERT INTO schema_migrations (version) VALUES ('20160223160404');

INSERT INTO schema_migrations (version) VALUES ('20160224111338');

INSERT INTO schema_migrations (version) VALUES ('20160224143937');

INSERT INTO schema_migrations (version) VALUES ('20160225090417');

INSERT INTO schema_migrations (version) VALUES ('20160225101236');

INSERT INTO schema_migrations (version) VALUES ('20160225113207');

INSERT INTO schema_migrations (version) VALUES ('20160225130400');

INSERT INTO schema_migrations (version) VALUES ('20160301111323');

INSERT INTO schema_migrations (version) VALUES ('20160322102813');

INSERT INTO schema_migrations (version) VALUES ('20160404123940');

INSERT INTO schema_migrations (version) VALUES ('20160405103708');

INSERT INTO schema_migrations (version) VALUES ('20160405145315');

INSERT INTO schema_migrations (version) VALUES ('20160412091417');

INSERT INTO schema_migrations (version) VALUES ('20160413135658');

INSERT INTO schema_migrations (version) VALUES ('20160413140153');

INSERT INTO schema_migrations (version) VALUES ('20160413143619');

INSERT INTO schema_migrations (version) VALUES ('20160413150715');

INSERT INTO schema_migrations (version) VALUES ('20160418130416');

INSERT INTO schema_migrations (version) VALUES ('20160422105349');

INSERT INTO schema_migrations (version) VALUES ('20160428124015');

INSERT INTO schema_migrations (version) VALUES ('20160428190215');

INSERT INTO schema_migrations (version) VALUES ('20160429134835');

INSERT INTO schema_migrations (version) VALUES ('20160504064153');

INSERT INTO schema_migrations (version) VALUES ('20160510122323');

INSERT INTO schema_migrations (version) VALUES ('20160510122324');

INSERT INTO schema_migrations (version) VALUES ('20160510122325');

INSERT INTO schema_migrations (version) VALUES ('20160510122326');

INSERT INTO schema_migrations (version) VALUES ('20160510122327');

INSERT INTO schema_migrations (version) VALUES ('20160510122328');

INSERT INTO schema_migrations (version) VALUES ('20160520134625');

INSERT INTO schema_migrations (version) VALUES ('20160630082357');

INSERT INTO schema_migrations (version) VALUES ('20160729100003');

INSERT INTO schema_migrations (version) VALUES ('20160816150906');

INSERT INTO schema_migrations (version) VALUES ('20160914133843');

INSERT INTO schema_migrations (version) VALUES ('20161208103043');

INSERT INTO schema_migrations (version) VALUES ('20170131103912');

