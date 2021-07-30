SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: editions_generate_tsvector(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.editions_generate_tsvector() RETURNS trigger
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
-- Name: approvals; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.approvals (
    id bigint NOT NULL,
    user_id bigint,
    edition_id bigint
);


--
-- Name: approvals_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.approvals_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: approvals_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.approvals_id_seq OWNED BY public.approvals.id;


--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: comments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.comments (
    id bigint NOT NULL,
    comment text,
    commentable_type character varying,
    commentable_id bigint,
    user_id bigint,
    role character varying DEFAULT 'comments'::character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: comments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.comments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.comments_id_seq OWNED BY public.comments.id;


--
-- Name: editions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.editions (
    id bigint NOT NULL,
    guide_id bigint,
    author_id bigint,
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

CREATE SEQUENCE public.editions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: editions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.editions_id_seq OWNED BY public.editions.id;


--
-- Name: guides; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.guides (
    id bigint NOT NULL,
    slug character varying,
    content_id character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    type character varying,
    tsv tsvector
);


--
-- Name: guides_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.guides_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: guides_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.guides_id_seq OWNED BY public.guides.id;


--
-- Name: redirects; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.redirects (
    id bigint NOT NULL,
    content_id text NOT NULL,
    old_path text NOT NULL,
    new_path text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: redirects_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.redirects_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: redirects_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.redirects_id_seq OWNED BY public.redirects.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: slug_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.slug_migrations (
    id bigint NOT NULL,
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

CREATE SEQUENCE public.slug_migrations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: slug_migrations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.slug_migrations_id_seq OWNED BY public.slug_migrations.id;


--
-- Name: topic_section_guides; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.topic_section_guides (
    id bigint NOT NULL,
    topic_section_id integer NOT NULL,
    guide_id integer NOT NULL,
    "position" integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: topic_section_guides_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.topic_section_guides_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: topic_section_guides_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.topic_section_guides_id_seq OWNED BY public.topic_section_guides.id;


--
-- Name: topic_sections; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.topic_sections (
    id bigint NOT NULL,
    topic_id integer NOT NULL,
    title character varying,
    description character varying,
    "position" integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: topic_sections_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.topic_sections_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: topic_sections_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.topic_sections_id_seq OWNED BY public.topic_sections.id;


--
-- Name: topics; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.topics (
    id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    path character varying NOT NULL,
    title character varying NOT NULL,
    description character varying NOT NULL,
    content_id character varying,
    visually_collapsed boolean DEFAULT false,
    include_on_homepage boolean DEFAULT true
);


--
-- Name: topics_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.topics_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: topics_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.topics_id_seq OWNED BY public.topics.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id bigint NOT NULL,
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

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: approvals id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.approvals ALTER COLUMN id SET DEFAULT nextval('public.approvals_id_seq'::regclass);


--
-- Name: comments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments ALTER COLUMN id SET DEFAULT nextval('public.comments_id_seq'::regclass);


--
-- Name: editions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.editions ALTER COLUMN id SET DEFAULT nextval('public.editions_id_seq'::regclass);


--
-- Name: guides id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.guides ALTER COLUMN id SET DEFAULT nextval('public.guides_id_seq'::regclass);


--
-- Name: redirects id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.redirects ALTER COLUMN id SET DEFAULT nextval('public.redirects_id_seq'::regclass);


--
-- Name: slug_migrations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.slug_migrations ALTER COLUMN id SET DEFAULT nextval('public.slug_migrations_id_seq'::regclass);


--
-- Name: topic_section_guides id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.topic_section_guides ALTER COLUMN id SET DEFAULT nextval('public.topic_section_guides_id_seq'::regclass);


--
-- Name: topic_sections id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.topic_sections ALTER COLUMN id SET DEFAULT nextval('public.topic_sections_id_seq'::regclass);


--
-- Name: topics id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.topics ALTER COLUMN id SET DEFAULT nextval('public.topics_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: approvals approvals_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.approvals
    ADD CONSTRAINT approvals_pkey PRIMARY KEY (id);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: comments comments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_pkey PRIMARY KEY (id);


--
-- Name: editions editions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.editions
    ADD CONSTRAINT editions_pkey PRIMARY KEY (id);


--
-- Name: guides guides_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.guides
    ADD CONSTRAINT guides_pkey PRIMARY KEY (id);


--
-- Name: redirects redirects_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.redirects
    ADD CONSTRAINT redirects_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: slug_migrations slug_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.slug_migrations
    ADD CONSTRAINT slug_migrations_pkey PRIMARY KEY (id);


--
-- Name: topic_section_guides topic_section_guides_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.topic_section_guides
    ADD CONSTRAINT topic_section_guides_pkey PRIMARY KEY (id);


--
-- Name: topic_sections topic_sections_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.topic_sections
    ADD CONSTRAINT topic_sections_pkey PRIMARY KEY (id);


--
-- Name: topics topics_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.topics
    ADD CONSTRAINT topics_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: guides_tsv_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX guides_tsv_idx ON public.guides USING gin (tsv);


--
-- Name: index_approvals_on_edition_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_approvals_on_edition_id ON public.approvals USING btree (edition_id);


--
-- Name: index_approvals_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_approvals_on_user_id ON public.approvals USING btree (user_id);


--
-- Name: index_comments_on_commentable_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_comments_on_commentable_type ON public.comments USING btree (commentable_type);


--
-- Name: index_comments_on_commentable_type_and_commentable_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_comments_on_commentable_type_and_commentable_id ON public.comments USING btree (commentable_type, commentable_id);


--
-- Name: index_comments_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_comments_on_user_id ON public.comments USING btree (user_id);


--
-- Name: index_editions_on_author_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_editions_on_author_id ON public.editions USING btree (author_id);


--
-- Name: index_editions_on_guide_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_editions_on_guide_id ON public.editions USING btree (guide_id);


--
-- Name: index_guides_on_content_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_guides_on_content_id ON public.guides USING btree (content_id);


--
-- Name: index_redirects_on_content_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_redirects_on_content_id ON public.redirects USING btree (content_id);


--
-- Name: index_slug_migrations_on_content_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_slug_migrations_on_content_id ON public.slug_migrations USING btree (content_id);


--
-- Name: index_slug_migrations_on_slug; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_slug_migrations_on_slug ON public.slug_migrations USING btree (slug);


--
-- Name: index_topic_section_guides_on_guide_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_topic_section_guides_on_guide_id ON public.topic_section_guides USING btree (guide_id);


--
-- Name: index_topic_section_guides_on_topic_section_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_topic_section_guides_on_topic_section_id ON public.topic_section_guides USING btree (topic_section_id);


--
-- Name: index_topic_sections_on_topic_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_topic_sections_on_topic_id ON public.topic_sections USING btree (topic_id);


--
-- Name: index_topics_on_content_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_topics_on_content_id ON public.topics USING btree (content_id);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_email ON public.users USING btree (email);


--
-- Name: index_users_on_organisation_content_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_organisation_content_id ON public.users USING btree (organisation_content_id);


--
-- Name: index_users_on_uid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_uid ON public.users USING btree (uid);


--
-- Name: editions tsvector_editions_upsert_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER tsvector_editions_upsert_trigger AFTER INSERT OR UPDATE ON public.editions FOR EACH ROW EXECUTE PROCEDURE public.editions_generate_tsvector();


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20151009125935'),
('20151012105912'),
('20151013102859'),
('20151013111221'),
('20151013114232'),
('20151013135813'),
('20151027095557'),
('20151102145752'),
('20151103120443'),
('20151105142126'),
('20151109142125'),
('20151110123937'),
('20151110135512'),
('20151110162230'),
('20151112133846'),
('20151116113920'),
('20151119131239'),
('20151211164627'),
('20151216125006'),
('20160107144631'),
('20160113110500'),
('20160115104456'),
('20160120143132'),
('20160209114249'),
('20160223095349'),
('20160223101735'),
('20160223160404'),
('20160224111338'),
('20160224143937'),
('20160225090417'),
('20160225101236'),
('20160225113207'),
('20160225130400'),
('20160301111323'),
('20160322102813'),
('20160404123940'),
('20160405103708'),
('20160405145315'),
('20160412091417'),
('20160413135658'),
('20160413140153'),
('20160413143619'),
('20160413150715'),
('20160418130416'),
('20160422105349'),
('20160428124015'),
('20160428190215'),
('20160429134835'),
('20160504064153'),
('20160510122323'),
('20160510122324'),
('20160510122325'),
('20160510122326'),
('20160510122327'),
('20160510122328'),
('20160520134625'),
('20160630082357'),
('20160729100003'),
('20160816150906'),
('20160914133843'),
('20161208103043'),
('20170131103912'),
('20200604155614');


