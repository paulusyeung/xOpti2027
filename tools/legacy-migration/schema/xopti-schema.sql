--
-- xOpti target schema (DDL only, no data) - snapshot for clean rebuilds before cutover.
-- Source: docker exec psql-17 pg_dump -U postgres --schema-only --no-owner --no-privileges xOpti
-- Captured: 2026-11-10 from xOpti @ psql-17 (PostgreSQL 17.11), 73 public tables + migration schema.
-- Regenerate the same way when the target DDL changes; transform's ADD COLUMN IF NOT EXISTS
-- is_synthetic is applied by the runner itself, no manual edits needed here.
--
-- Rebuild an empty target:
--   docker exec psql-17 psql -U postgres -c 'drop database if exists xOpti;'
--   docker exec psql-17 psql -U postgres -c 'create database xOpti;'
--   docker exec -i psql-17 psql -U postgres -d xOpti -v ON_ERROR_STOP=1 < tools/legacy-migration/schema/xopti-schema.sql
--

--
-- PostgreSQL database dump
--

\restrict BpMoA39so3cOdLKF6mtY4ufjVVsEIe9GcfSH726kaab2BdBjghHElr8lqf58vhJ

-- Dumped from database version 17.11
-- Dumped by pg_dump version 17.11

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: migration; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA migration;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: anomaly_quarantine; Type: TABLE; Schema: migration; Owner: -
--

CREATE TABLE migration.anomaly_quarantine (
    id bigint NOT NULL,
    run_id bigint,
    source_table text,
    pk text,
    kind text,
    detail text,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: anomaly_quarantine_id_seq; Type: SEQUENCE; Schema: migration; Owner: -
--

ALTER TABLE migration.anomaly_quarantine ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME migration.anomaly_quarantine_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: run_log; Type: TABLE; Schema: migration; Owner: -
--

CREATE TABLE migration.run_log (
    id bigint NOT NULL,
    command text NOT NULL,
    mode text NOT NULL,
    source_path text,
    source_sha256 text,
    started_at timestamp with time zone DEFAULT now() NOT NULL,
    ended_at timestamp with time zone,
    outcome text,
    details jsonb
);


--
-- Name: run_log_id_seq; Type: SEQUENCE; Schema: migration; Owner: -
--

ALTER TABLE migration.run_log ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME migration.run_log_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: add; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.add (
    add_code character varying(2) NOT NULL,
    add_description character varying(40)
);


--
-- Name: bar_code_pool; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bar_code_pool (
    id integer NOT NULL,
    tx_number character varying(10) NOT NULL,
    date_of_entry timestamp without time zone NOT NULL,
    sku character varying(13) NOT NULL,
    qty integer DEFAULT 0 NOT NULL
);


--
-- Name: barcode_pool_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.barcode_pool_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: barcode_pool_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.barcode_pool_id_seq OWNED BY public.bar_code_pool.id;


--
-- Name: branch; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.branch (
    branch_code character varying(3) NOT NULL,
    branch_name character varying(40) NOT NULL,
    contact_person character varying(40),
    job_title character varying(30),
    address1 character varying(40),
    address2 character varying(40),
    city character varying(20),
    province character varying(20),
    postal_code character varying(8),
    country character varying(20),
    phone character varying(13),
    fax character varying(13),
    summary_flag boolean
);


--
-- Name: branch_inventory; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.branch_inventory (
    branch_code character varying(4) NOT NULL,
    sku character varying(13) NOT NULL,
    qty_on_hand integer DEFAULT 0
);


--
-- Name: branch_summary; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.branch_summary (
    branch_code character varying(3) NOT NULL,
    year integer DEFAULT 0 NOT NULL,
    month integer DEFAULT 0 NOT NULL,
    first_date_of_month timestamp without time zone NOT NULL,
    qty_bf integer DEFAULT 0,
    amt_bf numeric(19,4) DEFAULT 0,
    qty_cd integer DEFAULT 0,
    amt_cd numeric(19,4) DEFAULT 0,
    qty_sold integer DEFAULT 0,
    amt_sold numeric(19,4) DEFAULT 0,
    amt_cost_of_goods_sold numeric(19,4) DEFAULT 0,
    qty_purchased integer DEFAULT 0,
    amt_purchased numeric(19,4) DEFAULT 0,
    qty_adjust_incr integer DEFAULT 0,
    amt_adjust_incr numeric(19,4) DEFAULT 0,
    qty_adjust_decr integer DEFAULT 0,
    amt_adjust_decr numeric(19,4) DEFAULT 0,
    qty_rejected integer DEFAULT 0,
    amt_rejected numeric(19,4) DEFAULT 0,
    qty_restocked integer DEFAULT 0,
    amt_restocked numeric(19,4) DEFAULT 0,
    qty_transfer_in integer DEFAULT 0,
    amt_transfer_in numeric(19,4) DEFAULT 0,
    qty_transfer_out integer DEFAULT 0,
    amt_transfer_out numeric(19,4) DEFAULT 0
);


--
-- Name: brand; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.brand (
    brand_code character varying(4) NOT NULL,
    brand_description character varying(40)
);


--
-- Name: category; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.category (
    department_code character varying(2) NOT NULL,
    class_code character varying(2) NOT NULL,
    category_code character varying(2) NOT NULL,
    category_name character varying(30),
    costing_method character varying(1) DEFAULT '0'::character varying NOT NULL,
    inventory_method character varying(1) DEFAULT '0'::character varying NOT NULL,
    tax_method character varying(1) DEFAULT '0'::character varying NOT NULL,
    summary_flag boolean
);


--
-- Name: class; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.class (
    department character varying(2) NOT NULL,
    class_code character varying(2) NOT NULL,
    class_name character varying(30),
    summary_flag boolean
);


--
-- Name: department; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.department (
    department_code character varying(2) NOT NULL,
    department_name character varying(30),
    summary_flag boolean
);


--
-- Name: category_query; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.category_query AS
 SELECT department.department_code,
    department.department_name,
    class.class_code,
    class.class_name,
    category.costing_method,
    category.inventory_method,
    category.tax_method,
    category.summary_flag,
    category.category_code,
    category.category_name
   FROM (public.department
     JOIN (public.class
     JOIN public.category ON ((((category.department_code)::text = (class.department)::text) AND ((class.class_code)::text = (category.class_code)::text)))) ON (((department.department_code)::text = (class.department)::text)));


--
-- Name: category_summary; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.category_summary (
    department_code character varying(2) NOT NULL,
    class_code character varying(2) NOT NULL,
    category_code character varying(2) NOT NULL,
    year integer DEFAULT 0 NOT NULL,
    month integer DEFAULT 0 NOT NULL,
    first_date_of_month timestamp without time zone NOT NULL,
    qty_bf integer DEFAULT 0,
    amt_bf numeric(19,4) DEFAULT 0,
    qty_cd integer DEFAULT 0,
    amt_cd numeric(19,4) DEFAULT 0,
    qty_sold integer DEFAULT 0,
    amt_sold numeric(19,4) DEFAULT 0,
    amt_cost_of_goods_sold numeric(19,4) DEFAULT 0,
    qty_purchased integer DEFAULT 0,
    amt_purchased numeric(19,4) DEFAULT 0,
    qty_adjusted_incr integer DEFAULT 0,
    amt_adjusted_incr numeric(19,4) DEFAULT 0,
    qty_adjusted_decr integer DEFAULT 0,
    amt_adjusted_decr numeric(19,4) DEFAULT 0,
    qty_rejected integer DEFAULT 0,
    amt_rejected numeric(19,4) DEFAULT 0,
    qty_restocked integer DEFAULT 0,
    amt_restocked numeric(19,4) DEFAULT 0,
    qty_transfer_in integer DEFAULT 0,
    amt_transfer_in numeric(19,4) DEFAULT 0,
    qty_transfer_out integer DEFAULT 0,
    amt_transfer_out numeric(19,4) DEFAULT 0
);


--
-- Name: city; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.city (
    code integer NOT NULL,
    city_phone_code character varying(4),
    city_name character varying(26) NOT NULL,
    province_code character varying(2) NOT NULL,
    country_code character varying(3) NOT NULL
);


--
-- Name: city_code_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.city_code_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: city_code_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.city_code_seq OWNED BY public.city.code;


--
-- Name: country; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.country (
    country_name character varying(26) NOT NULL,
    country_code character varying(3) NOT NULL,
    country_phone_code character varying(4)
);


--
-- Name: province; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.province (
    province_name character varying(26) NOT NULL,
    province_code character varying(2) NOT NULL
);


--
-- Name: city_query; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.city_query AS
 SELECT DISTINCT city.code,
    city.city_name,
    city.city_phone_code,
    city.province_code,
    city.country_code,
    province.province_name,
    country.country_name
   FROM ((public.city
     JOIN public.province ON (((city.province_code)::text = (province.province_code)::text)))
     JOIN public.country ON (((city.country_code)::text = (country.country_code)::text)));


--
-- Name: class_query; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.class_query AS
 SELECT class.department,
    department.department_name,
    class.class_code,
    class.class_name,
    class.summary_flag
   FROM (public.department
     RIGHT JOIN public.class ON (((department.department_code)::text = (class.department)::text)))
  ORDER BY class.department, department.department_name, class.class_code, class.class_name, class.summary_flag;


--
-- Name: class_summary; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.class_summary (
    department_code character varying(2) NOT NULL,
    class_code character varying(2) NOT NULL,
    year integer DEFAULT 0 NOT NULL,
    month integer DEFAULT 0 NOT NULL,
    first_date_of_month timestamp without time zone NOT NULL,
    qty_bf integer DEFAULT 0,
    amt_bf numeric(19,4) DEFAULT 0,
    qty_cd integer DEFAULT 0,
    amt_cd numeric(19,4) DEFAULT 0,
    qty_sold integer DEFAULT 0,
    amt_sold numeric(19,4) DEFAULT 0,
    amt_cost_of_goods_sold numeric(19,4) DEFAULT 0,
    qty_purchased integer DEFAULT 0,
    amt_purchased numeric(19,4) DEFAULT 0,
    qty_adjusted_incr integer DEFAULT 0,
    amt_adjusted_incr numeric(19,4) DEFAULT 0,
    qty_adjusted_decr integer DEFAULT 0,
    amt_adjusted_decr numeric(19,4) DEFAULT 0,
    qty_rejected integer DEFAULT 0,
    amt_rejected numeric(19,4) DEFAULT 0,
    qty_restocked integer DEFAULT 0,
    amt_restocked numeric(19,4) DEFAULT 0,
    qty_transfer_in integer DEFAULT 0,
    amt_transfer_in numeric(19,4) DEFAULT 0,
    qty_transfer_out integer DEFAULT 0,
    amt_transfer_out numeric(19,4) DEFAULT 0
);


--
-- Name: costing_method; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.costing_method (
    costing_code character varying(1) NOT NULL,
    costing_name character varying(10) NOT NULL
);


--
-- Name: customer; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.customer (
    id integer NOT NULL,
    vip_code character varying(16),
    first_name character varying(20),
    initial character varying(2),
    last_name character varying(20),
    full_name character varying(40),
    salutation character varying(4),
    birthday timestamp without time zone,
    home_address character varying(128),
    home_city integer DEFAULT 0,
    home_province character varying(2),
    home_postal_code character varying(8),
    home_country character varying(3),
    home_phone character varying(12),
    home_fax character varying(12),
    cellular character varying(15),
    email character varying(128),
    biz_company_name character varying(40),
    biz_job_title character varying(20),
    biz_address character varying(128),
    biz_city integer DEFAULT 0,
    biz_province character varying(2),
    biz_postal_code character varying(8),
    biz_country character varying(3),
    biz_phone character varying(12),
    biz_fax character varying(12),
    credit_limit numeric(19,4) DEFAULT 0,
    payment_terms character varying(10),
    vip_mark_down_pct double precision DEFAULT 0,
    summary_flag boolean,
    accounting_flag boolean,
    remarks text
);


--
-- Name: customer_accounts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.customer_accounts (
    customer_id integer DEFAULT 0 NOT NULL,
    joint_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    ttl_amt_purchased numeric(19,4) DEFAULT 0,
    ttl_amt_refund numeric(19,4) DEFAULT 0,
    ttl_amt_mrkdwn_applied numeric(19,4) DEFAULT 0,
    ttl_amt_cpn_used numeric(19,4) DEFAULT 0,
    ytd_amt_purchased numeric(19,4) DEFAULT 0,
    ytd_amt_refund numeric(19,4) DEFAULT 0,
    ytd_amt_mrkdwn_applied numeric(19,4) DEFAULT 0,
    ytd_amt_cpn_used numeric(19,4) DEFAULT 0,
    last_purchase_date timestamp without time zone
);


--
-- Name: customer_accounts_query; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.customer_accounts_query AS
 SELECT last_purchase_date
   FROM public.customer_accounts;


--
-- Name: customer_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.customer_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: customer_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.customer_id_seq OWNED BY public.customer.id;


--
-- Name: customer_medical; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.customer_medical (
    customer_id integer DEFAULT 0 NOT NULL,
    ins_maturity_date timestamp without time zone,
    care_card_no character varying(10),
    care_card_valid_period character varying(4),
    care_card_type character varying(4),
    prescription_lens_flag boolean,
    prescription_contact_flag boolean
);


--
-- Name: customer_pres_contact; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.customer_pres_contact (
    customer_id integer DEFAULT 0 NOT NULL,
    issued_on timestamp without time zone,
    issued_by_dr integer DEFAULT 0,
    right_sphere double precision DEFAULT 0,
    right_cylinder double precision DEFAULT 0,
    right_axis integer DEFAULT 0,
    right_k_reading_v double precision DEFAULT 0,
    right_k_reading_h double precision DEFAULT 0,
    right_palp double precision DEFAULT 0,
    right_corn double precision DEFAULT 0,
    right_pupil double precision DEFAULT 0,
    left_sphere double precision DEFAULT 0,
    left_cylinder double precision DEFAULT 0,
    left_axis integer DEFAULT 0,
    left_k_reading_v double precision DEFAULT 0,
    left_k_reading_h double precision DEFAULT 0,
    left_palp double precision DEFAULT 0,
    left_corn double precision DEFAULT 0,
    left_pupil double precision DEFAULT 0,
    history character varying(56),
    medical character varying(56),
    allergy character varying(56),
    reason character varying(56),
    evaluation character varying(56),
    test character varying(56)
);


--
-- Name: customer_pres_lens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.customer_pres_lens (
    customer_id integer DEFAULT 0 NOT NULL,
    issued_on timestamp without time zone,
    issued_by_dr integer DEFAULT 0,
    right_sphere double precision DEFAULT 0,
    right_cylinder double precision DEFAULT 0,
    right_axis integer DEFAULT 0,
    right_pd_dist double precision DEFAULT 0,
    right_pd_near double precision DEFAULT 0,
    right_prism double precision DEFAULT 0,
    right_add double precision DEFAULT 0,
    right_pupil double precision DEFAULT 0,
    left_sphere double precision DEFAULT 0,
    left_cylinder double precision DEFAULT 0,
    left_axis integer DEFAULT 0,
    left_pd_dist double precision DEFAULT 0,
    left_pd_near double precision DEFAULT 0,
    left_prism double precision DEFAULT 0,
    left_add double precision DEFAULT 0,
    left_pupil double precision DEFAULT 0
);


--
-- Name: customer_query; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.customer_query AS
 SELECT id,
    vip_code,
    first_name,
    initial,
    last_name,
    full_name,
    birthday,
    home_city,
    home_country,
    home_phone,
    home_fax,
    biz_city,
    biz_country,
    biz_phone,
    biz_fax,
    biz_province
   FROM public.customer;


--
-- Name: department_query; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.department_query AS
 SELECT department_code,
    department_name,
    summary_flag
   FROM public.department;


--
-- Name: dept_summary; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dept_summary (
    department_code character varying(2) NOT NULL,
    year integer DEFAULT 0 NOT NULL,
    month integer DEFAULT 0 NOT NULL,
    first_date_of_month timestamp without time zone NOT NULL,
    qty_bf integer DEFAULT 0,
    amt_bf numeric(19,4) DEFAULT 0,
    qty_cd integer DEFAULT 0,
    amt_cd numeric(19,4) DEFAULT 0,
    qty_sold integer DEFAULT 0,
    amt_sold numeric(19,4) DEFAULT 0,
    amt_cost_of_goods_sold numeric(19,4) DEFAULT 0,
    qty_purchased integer DEFAULT 0,
    amt_purchased numeric(19,4) DEFAULT 0,
    qty_adjusted_incr integer DEFAULT 0,
    amt_adjusted_incr numeric(19,4) DEFAULT 0,
    qty_adjusted_decr integer DEFAULT 0,
    amt_adjusted_decr numeric(19,4) DEFAULT 0,
    qty_rejected integer DEFAULT 0,
    amt_rejected numeric(19,4) DEFAULT 0,
    qty_restocked integer DEFAULT 0,
    amt_restocked numeric(19,4) DEFAULT 0,
    qty_transfer_in integer DEFAULT 0,
    amt_transfer_in numeric(19,4) DEFAULT 0,
    qty_transfer_out integer DEFAULT 0,
    amt_transfer_out numeric(19,4) DEFAULT 0
);


--
-- Name: doctor; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.doctor (
    id integer NOT NULL,
    doctor_name character varying(40),
    address character varying(128),
    city integer DEFAULT 0,
    province character varying(2),
    country character varying(3),
    phone character varying(10),
    postal_code character varying(7),
    fax character varying(10),
    emergency character varying(15)
);


--
-- Name: doctor_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.doctor_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: doctor_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.doctor_id_seq OWNED BY public.doctor.id;


--
-- Name: tx_details; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tx_details (
    control_number character varying(10) NOT NULL,
    tx_type character varying(2) NOT NULL,
    tx_number character varying(10) NOT NULL,
    date_of_entry timestamp without time zone NOT NULL,
    row_no double precision DEFAULT 0 NOT NULL,
    sku character varying(13) NOT NULL,
    remarks text,
    prescription_lens_flag boolean,
    prescription_contact_flag boolean,
    qty integer DEFAULT 0,
    unit_amount numeric(19,4) DEFAULT 0,
    unit_cost numeric(19,4) DEFAULT 0,
    unit_lsp numeric(19,4) DEFAULT 0,
    mark_down_percent double precision DEFAULT 0,
    mark_down_amount numeric(19,4) DEFAULT 0,
    amount numeric(19,4) DEFAULT 0,
    tax_code character varying(1)
);


--
-- Name: fix_missed_tx_header__tx_details; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.fix_missed_tx_header__tx_details AS
 SELECT tx_number,
    control_number,
    count(*) AS counts
   FROM public.tx_details
  GROUP BY tx_number, control_number
  ORDER BY tx_number;


--
-- Name: tx_payment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tx_payment (
    tx_number character varying(10) NOT NULL,
    payment_line_no double precision DEFAULT 0 NOT NULL,
    type character varying(1) NOT NULL,
    card_number character varying(30),
    authorization_code character varying(10),
    amount_tender numeric(19,4) DEFAULT 0,
    exchange_rate double precision DEFAULT 0,
    eq_amount numeric(19,4) DEFAULT 0,
    total_this_pay numeric(19,4) DEFAULT 0
);


--
-- Name: fix_missed_tx_header__tx_payment; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.fix_missed_tx_header__tx_payment AS
 SELECT tx_number,
    count(*) AS counts
   FROM public.tx_payment
  GROUP BY tx_number
  ORDER BY tx_number;


--
-- Name: tx_header; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tx_header (
    control_number character varying(10) NOT NULL,
    tx_type character varying(2) NOT NULL,
    tx_number character varying(10) NOT NULL,
    date_of_entry timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    date_of_creation timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    ref_number character varying(10),
    tracking_number character varying(10),
    customer_id integer DEFAULT 0,
    supplier_code character varying(4),
    second_date timestamp without time zone,
    particulars text,
    total_cost numeric(19,4) DEFAULT 0,
    total_sale numeric(19,4) DEFAULT 0,
    tax_a numeric(19,4) DEFAULT 0,
    tax_b numeric(19,4) DEFAULT 0,
    tax_c numeric(19,4) DEFAULT 0,
    other_charges numeric(19,4) DEFAULT 0,
    gross_sale numeric(19,4) DEFAULT 0,
    sales_discount numeric(19,4) DEFAULT 0,
    total_amount numeric(19,4) DEFAULT 0,
    total_qty integer DEFAULT 0,
    previous_paid numeric(19,4) DEFAULT 0,
    this_paid numeric(19,4) DEFAULT 0,
    change numeric(19,4) DEFAULT 0,
    print_counter integer DEFAULT 0,
    payment_link smallint DEFAULT 0,
    sales_person_link smallint DEFAULT 0,
    status character varying(1)
);


--
-- Name: fix_missed_tx_header__tx_header; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.fix_missed_tx_header__tx_header AS
 SELECT d.control_number,
    'RC'::text AS tx_type,
    h.ref_number AS tx_number,
    h.second_date AS date_of_entry,
    h.second_date AS date_of_creation,
    h.tx_number AS ref_number,
    h.tracking_number,
    h.customer_id,
    h.supplier_code,
    h.date_of_entry AS second_date,
    h.particulars,
    h.total_cost,
    h.total_sale,
    h.tax_a,
    h.tax_b,
    h.tax_c,
    h.other_charges,
    h.gross_sale,
    h.sales_discount,
    h.total_amount,
    h.total_qty,
    h.this_paid AS previous_paid,
    (h.total_amount - h.this_paid) AS this_paid,
    h.change,
    h.print_counter,
        CASE
            WHEN (p.tx_number IS NULL) THEN (0)::bigint
            ELSE p.counts
        END AS payment_link,
    h.sales_person_link,
    0 AS status
   FROM ((public.fix_missed_tx_header__tx_details d
     JOIN public.tx_header h ON (((d.tx_number)::text = (h.ref_number)::text)))
     LEFT JOIN public.fix_missed_tx_header__tx_payment p ON (((h.ref_number)::text = (p.tx_number)::text)));


--
-- Name: footer; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.footer (
    footer_code character varying(2) NOT NULL,
    footer_description character varying(56),
    footer_note text
);


--
-- Name: hardening; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.hardening (
    id integer NOT NULL,
    name character varying(30) NOT NULL
);


--
-- Name: hardening_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.hardening_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: hardening_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.hardening_id_seq OWNED BY public.hardening.id;


--
-- Name: inventory; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.inventory (
    department_code character varying(2) NOT NULL,
    class_code character varying(2) NOT NULL,
    category_code character varying(2) NOT NULL,
    supplier_code character varying(4) NOT NULL,
    brand_code character varying(4) NOT NULL,
    model character varying(30),
    color character varying(8),
    size character varying(6),
    bridge integer DEFAULT 0,
    temple integer DEFAULT 0,
    add_code character varying(2),
    material_code character varying(2),
    sphere double precision DEFAULT 0,
    cylinder double precision DEFAULT 0,
    axis integer DEFAULT 0,
    base_curve double precision DEFAULT 0,
    diameter double precision DEFAULT 0,
    sku character varying(13) NOT NULL,
    name character varying(40),
    description text,
    remarks text,
    abc_grading character varying(1),
    inventory_type character varying(1),
    inventory_status character varying(1),
    kit_set_flag boolean,
    average_cost numeric(19,4) DEFAULT 0,
    re_order_level integer DEFAULT 0,
    re_order_qty integer DEFAULT 0,
    qty_total_on_hand integer DEFAULT 0,
    qty_sale_order integer DEFAULT 0,
    qty_purchase_order integer DEFAULT 0,
    qty_holded integer DEFAULT 0,
    qty_in_transit integer DEFAULT 0,
    date_last_issued timestamp without time zone,
    date_last_received timestamp without time zone,
    retail_price_flag boolean,
    whole_sale_price_flag boolean,
    inventory_lot_flag boolean
);


--
-- Name: material; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.material (
    material_code character varying(2) NOT NULL,
    material_description character varying(40)
);


--
-- Name: retail_price; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.retail_price (
    sku character varying(13) NOT NULL,
    least_selling_price numeric(19,4) DEFAULT 0,
    retail_price numeric(19,4) DEFAULT 0,
    retail_markdown_amt numeric(19,4) DEFAULT 0,
    retail_markdown_pct double precision DEFAULT 0
);


--
-- Name: supplier; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.supplier (
    supplier_code character varying(4) NOT NULL,
    supplier_name character varying(50),
    address character varying(128),
    city integer DEFAULT 0,
    province character varying(2),
    post_code character varying(8),
    country character varying(3),
    phone_gen_voice character varying(12),
    phone_gen_fax character varying(12),
    phone_ac_dept_ext character varying(12),
    phone_ac_dept_fax character varying(12),
    phone_sale_ext character varying(12),
    phone_sale_fax character varying(12),
    phone_service_ext character varying(12),
    phone_service_fax character varying(12),
    account_no character varying(8),
    date_started timestamp without time zone,
    credit_limit numeric(19,4) DEFAULT 0,
    payment_terms character varying(10),
    contact_person character varying(40),
    contact_person_flag character varying(1),
    summary_flag character varying(1),
    branch_flag character varying(1),
    remarks text,
    gst_number character varying(10),
    pst_number character varying(10),
    toll_free_phone1 character varying(24),
    toll_free_phone2 character varying(24),
    toll_free_fax1 character varying(24),
    toll_free_fax2 character varying(24)
);


--
-- Name: inventory_query; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.inventory_query AS
 SELECT department.department_name,
    class.class_name,
    category.category_name,
    supplier.supplier_name,
    brand.brand_description,
    material.material_description,
    inventory.department_code,
    inventory.class_code,
    inventory.category_code,
    inventory.supplier_code,
    inventory.brand_code,
    inventory.model,
    inventory.color,
    inventory.size,
    inventory.bridge,
    inventory.temple,
    inventory.add_code,
    inventory.material_code,
    inventory.sphere,
    inventory.cylinder,
    inventory.axis,
    inventory.base_curve,
    inventory.diameter,
    inventory.sku,
    inventory.name,
    inventory.description,
    inventory.remarks,
    inventory.abc_grading,
    inventory.inventory_type,
    inventory.inventory_status,
    inventory.kit_set_flag,
    inventory.average_cost,
    inventory.re_order_level,
    inventory.re_order_qty,
    inventory.qty_total_on_hand,
    inventory.qty_sale_order,
    inventory.qty_purchase_order,
    inventory.qty_holded,
    inventory.qty_in_transit,
    inventory.date_last_issued,
    inventory.date_last_received,
    inventory.retail_price_flag,
    inventory.whole_sale_price_flag,
    inventory.inventory_lot_flag,
    category.tax_method,
    retail_price.least_selling_price,
    retail_price.retail_price,
    retail_price.retail_markdown_amt,
    retail_price.retail_markdown_pct
   FROM (public.supplier
     RIGHT JOIN (public.material
     RIGHT JOIN (public.department
     JOIN (public.class
     JOIN (public.category
     JOIN (public.brand
     RIGHT JOIN (public.retail_price
     RIGHT JOIN public.inventory ON (((retail_price.sku)::text = (inventory.sku)::text))) ON (((brand.brand_code)::text = (inventory.brand_code)::text))) ON ((((category.category_code)::text = (inventory.category_code)::text) AND ((category.class_code)::text = (inventory.class_code)::text) AND ((category.department_code)::text = (inventory.department_code)::text)))) ON ((((class.class_code)::text = (category.class_code)::text) AND ((class.department)::text = (category.department_code)::text)))) ON (((department.department_code)::text = (class.department)::text))) ON (((material.material_code)::text = (inventory.material_code)::text))) ON (((supplier.supplier_code)::text = (inventory.supplier_code)::text)))
  ORDER BY department.department_code, class.class_code, category.category_code;


--
-- Name: invt_lot_record; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.invt_lot_record (
    sku character varying(13) NOT NULL,
    lot_no character varying(10) NOT NULL,
    date_received timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    supplier_code character varying(4) NOT NULL,
    qty_purchased integer DEFAULT 0,
    qty_used integer DEFAULT 0,
    qty_on_hand integer DEFAULT 0,
    unit_amount_purchased numeric(19,4) DEFAULT 0,
    total_amount_purchased numeric(19,4) DEFAULT 0
);


--
-- Name: invt_method; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.invt_method (
    invt_method_code character varying(1) NOT NULL,
    invt_method_name character varying(15) NOT NULL
);


--
-- Name: invt_st_details; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.invt_st_details (
    id integer NOT NULL,
    header_id integer DEFAULT 0 NOT NULL,
    sku character varying(13) NOT NULL,
    computer_qty double precision DEFAULT 0,
    physical_qty double precision DEFAULT 0,
    diff_qty double precision DEFAULT 0,
    average_cost numeric(19,4) DEFAULT 0
);


--
-- Name: invt_st_details_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.invt_st_details_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: invt_st_details_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.invt_st_details_id_seq OWNED BY public.invt_st_details.id;


--
-- Name: invt_st_header; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.invt_st_header (
    id integer NOT NULL,
    name character varying(30) NOT NULL,
    date_of_creation timestamp without time zone,
    date_of_update timestamp without time zone,
    date_of_purge timestamp without time zone,
    status smallint DEFAULT 0
);


--
-- Name: invt_st_header_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.invt_st_header_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: invt_st_header_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.invt_st_header_id_seq OWNED BY public.invt_st_header.id;


--
-- Name: invt_st_import; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.invt_st_import (
    header_id integer DEFAULT 0 NOT NULL,
    sku character varying(13) NOT NULL,
    qty integer DEFAULT 0,
    status integer DEFAULT 0
);


--
-- Name: invt_st_status; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.invt_st_status (
    code smallint DEFAULT 0 NOT NULL,
    name character varying(10) NOT NULL
);


--
-- Name: invt_summary; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.invt_summary (
    sku character varying(13) NOT NULL,
    year integer DEFAULT 0 NOT NULL,
    month integer DEFAULT 0 NOT NULL,
    first_date_of_month timestamp without time zone NOT NULL,
    qty_bf integer DEFAULT 0,
    amt_bf numeric(19,4) DEFAULT 0,
    qty_cd integer DEFAULT 0,
    amt_cd numeric(19,4) DEFAULT 0,
    qty_sold integer DEFAULT 0,
    amt_sold numeric(19,4) DEFAULT 0,
    amt_cost_of_goods_sold numeric(19,4) DEFAULT 0,
    qty_purchased integer DEFAULT 0,
    amt_purchased numeric(19,4) DEFAULT 0,
    qty_adj_incr integer DEFAULT 0,
    amt_adj_incr numeric(19,4) DEFAULT 0,
    qty_adj_decr integer DEFAULT 0,
    amt_adj_decr numeric(19,4) DEFAULT 0,
    qty_rejected integer DEFAULT 0,
    amt_rejected numeric(19,4) DEFAULT 0,
    qty_restocked integer DEFAULT 0,
    amt_restocked numeric(19,4) DEFAULT 0,
    qty_transfer_in integer DEFAULT 0,
    amt_transfer_in numeric(19,4) DEFAULT 0,
    qty_transfer_out integer DEFAULT 0,
    amt_transfer_out numeric(19,4) DEFAULT 0
);


--
-- Name: invt_summary_query; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.invt_summary_query AS
 SELECT department.department_name,
    class.class_name,
    category.category_name,
    invt_summary.sku,
    invt_summary.year,
    invt_summary.month,
    invt_summary.first_date_of_month,
    invt_summary.qty_bf,
    invt_summary.amt_bf,
    invt_summary.qty_cd,
    invt_summary.amt_cd,
    invt_summary.qty_sold,
    invt_summary.amt_sold,
    invt_summary.amt_cost_of_goods_sold,
    invt_summary.qty_purchased,
    invt_summary.amt_purchased,
    invt_summary.qty_adj_incr,
    invt_summary.amt_adj_incr,
    invt_summary.qty_adj_decr,
    invt_summary.amt_adj_decr,
    invt_summary.qty_rejected,
    invt_summary.amt_rejected,
    invt_summary.qty_restocked,
    invt_summary.amt_restocked,
    invt_summary.qty_transfer_in,
    invt_summary.amt_transfer_in,
    invt_summary.qty_transfer_out,
    invt_summary.amt_transfer_out
   FROM (((public.department
     JOIN (public.class
     JOIN public.category ON ((((class.class_code)::text = (category.class_code)::text) AND ((class.department)::text = (category.department_code)::text)))) ON (((department.department_code)::text = (class.department)::text)))
     JOIN public.inventory ON ((((department.department_code)::text = (inventory.department_code)::text) AND ((category.category_code)::text = (inventory.category_code)::text) AND ((category.class_code)::text = (inventory.class_code)::text) AND ((category.department_code)::text = (inventory.department_code)::text))))
     JOIN public.invt_summary ON (((inventory.sku)::text = (invt_summary.sku)::text)))
  ORDER BY department.department_code, class.class_code, category.category_code;


--
-- Name: job_nature; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.job_nature (
    code character varying(1) NOT NULL,
    name character varying(20) NOT NULL
);


--
-- Name: job_status; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.job_status (
    code character varying(1) NOT NULL,
    name character varying(20) NOT NULL
);


--
-- Name: job_title; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.job_title (
    job_title_code character varying(4) NOT NULL,
    job_title character varying(30) NOT NULL
);


--
-- Name: marital_status; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.marital_status (
    code character varying(1) NOT NULL,
    marital_status character varying(15) NOT NULL
);


--
-- Name: olap_category_summary; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.olap_category_summary AS
 SELECT department.department_name,
    class.class_name,
    category.category_name,
    category_summary.year,
    EXTRACT(quarter FROM category_summary.first_date_of_month) AS quarter,
    category_summary.month,
    category_summary.qty_cd,
    category_summary.amt_cd,
    (category_summary.qty_sold + category_summary.qty_restocked) AS units,
    (category_summary.amt_sold + category_summary.amt_restocked) AS sales,
    ((category_summary.amt_sold + category_summary.amt_restocked) - category_summary.amt_cost_of_goods_sold) AS margin,
    category_summary.amt_cost_of_goods_sold AS cost
   FROM (public.category_summary
     JOIN (public.department
     JOIN (public.class
     JOIN public.category ON ((((class.class_code)::text = (category.class_code)::text) AND ((class.department)::text = (category.department_code)::text)))) ON (((department.department_code)::text = (class.department)::text))) ON ((((category_summary.category_code)::text = (category.category_code)::text) AND ((category_summary.class_code)::text = (category.class_code)::text) AND ((category_summary.department_code)::text = (category.department_code)::text))))
  ORDER BY department.department_name, class.class_name, category.category_name;


--
-- Name: olap_order_in_progress; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.olap_order_in_progress AS
 SELECT DISTINCT concat_ws(' (H): '::text, customer.full_name, customer.home_phone) AS customer,
    tx_header.tx_number AS order_no,
    EXTRACT(year FROM tx_header.date_of_entry) AS year,
    EXTRACT(quarter FROM tx_header.date_of_entry) AS quarter,
    EXTRACT(month FROM tx_header.date_of_entry) AS month,
    tx_header.date_of_entry,
    tx_header.total_cost AS cost,
    tx_header.total_sale AS sales,
    tx_header.tax_a AS gst,
    tx_header.tax_b AS pst,
    tx_header.gross_sale,
    tx_header.this_paid AS deposit,
    (tx_header.gross_sale - tx_header.this_paid) AS balance
   FROM (public.customer
     JOIN public.tx_header ON ((customer.id = tx_header.customer_id)))
  WHERE (((tx_header.tx_type)::text = 'SA'::text) AND ((tx_header.status)::text = '1'::text))
  ORDER BY (concat_ws(' (H): '::text, customer.full_name, customer.home_phone)), tx_header.date_of_entry;


--
-- Name: olap_order_in_progress1; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.olap_order_in_progress1 AS
 SELECT DISTINCT customer.full_name,
    concat_ws(' (H): '::text, customer.full_name, customer.home_phone) AS customer,
    tx_header.tx_number AS order_no,
    EXTRACT(year FROM tx_header.date_of_entry) AS year,
    EXTRACT(quarter FROM tx_header.date_of_entry) AS quarter,
    EXTRACT(month FROM tx_header.date_of_entry) AS month,
    tx_header.date_of_entry,
    tx_header.total_cost AS cost,
    tx_header.total_sale AS sales,
    tx_header.tax_a AS gst,
    tx_header.tax_b AS pst,
    tx_header.gross_sale,
    tx_header.this_paid AS deposit,
    (tx_header.gross_sale - tx_header.this_paid) AS balance
   FROM (public.customer
     JOIN public.tx_header ON ((customer.id = tx_header.customer_id)))
  WHERE (((tx_header.tx_type)::text = 'SA'::text) AND ((tx_header.status)::text = '1'::text))
  ORDER BY customer.full_name, tx_header.date_of_entry;


--
-- Name: olap_sales; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.olap_sales AS
 SELECT DISTINCT department.department_name,
    class.class_name,
    category.category_name,
    supplier.supplier_name,
    brand.brand_description,
    inventory.model,
    inventory.color,
    inventory.size,
    tx_header.date_of_entry,
    EXTRACT(year FROM tx_header.date_of_entry) AS year,
    EXTRACT(month FROM tx_header.date_of_entry) AS month,
    EXTRACT(quarter FROM tx_header.date_of_entry) AS quarter,
    tx_details.qty,
    tx_details.unit_cost,
    tx_details.unit_amount,
    tx_details.amount,
    tx_details.qty AS units,
    tx_details.amount AS sales,
    (tx_details.amount - ((tx_details.qty)::numeric * tx_details.unit_cost)) AS margin,
    ((tx_details.qty)::numeric * tx_details.unit_cost) AS cost,
    inventory.sku,
    inventory.sphere,
    inventory.cylinder
   FROM (((((((public.tx_header
     LEFT JOIN public.tx_details ON (((tx_header.tx_number)::text = (tx_details.tx_number)::text)))
     LEFT JOIN public.inventory ON (((tx_details.sku)::text = (inventory.sku)::text)))
     LEFT JOIN public.supplier ON (((inventory.supplier_code)::text = (supplier.supplier_code)::text)))
     LEFT JOIN public.brand ON (((inventory.brand_code)::text = (brand.brand_code)::text)))
     LEFT JOIN public.category ON ((((inventory.category_code)::text = (category.category_code)::text) AND ((inventory.class_code)::text = (category.class_code)::text) AND ((inventory.department_code)::text = (category.department_code)::text))))
     LEFT JOIN public.class ON ((((category.class_code)::text = (class.class_code)::text) AND ((category.department_code)::text = (class.department)::text))))
     LEFT JOIN public.department ON (((class.department)::text = (department.department_code)::text)))
  WHERE (((tx_header.tx_type)::text = 'RC'::text) OR (((tx_header.tx_type)::text = 'RS'::text) AND (((tx_header.ref_number)::character varying)::text ~~ 'RC%'::text)))
  ORDER BY department.department_name, class.class_name, category.category_name, brand.brand_description, inventory.model, inventory.color, inventory.size, tx_header.date_of_entry;


--
-- Name: olap_sales_lsp; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.olap_sales_lsp AS
 SELECT DISTINCT department.department_name,
    class.class_name,
    category.category_name,
    supplier.supplier_name,
    brand.brand_description,
    inventory.model,
    inventory.color,
    inventory.size,
    tx_header.date_of_entry,
    EXTRACT(year FROM tx_header.date_of_entry) AS year,
    EXTRACT(month FROM tx_header.date_of_entry) AS month,
    EXTRACT(quarter FROM tx_header.date_of_entry) AS quarter,
    tx_details.qty,
    tx_details.unit_lsp,
    tx_details.unit_amount,
    tx_details.amount,
    tx_details.qty AS units,
    tx_details.amount AS sales,
    (tx_details.amount - ((tx_details.qty)::numeric * tx_details.unit_lsp)) AS margin,
    ((tx_details.qty)::numeric * tx_details.unit_lsp) AS cost,
    inventory.sku
   FROM (((((((public.tx_header
     LEFT JOIN public.tx_details ON (((tx_header.tx_number)::text = (tx_details.tx_number)::text)))
     LEFT JOIN public.inventory ON (((tx_details.sku)::text = (inventory.sku)::text)))
     LEFT JOIN public.supplier ON (((inventory.supplier_code)::text = (supplier.supplier_code)::text)))
     LEFT JOIN public.brand ON (((inventory.brand_code)::text = (brand.brand_code)::text)))
     LEFT JOIN public.category ON ((((inventory.department_code)::text = (category.department_code)::text) AND ((inventory.class_code)::text = (category.class_code)::text) AND ((inventory.category_code)::text = (category.category_code)::text))))
     LEFT JOIN public.class ON ((((category.department_code)::text = (class.department)::text) AND ((category.class_code)::text = (class.class_code)::text))))
     LEFT JOIN public.department ON (((class.department)::text = (department.department_code)::text)))
  WHERE (((tx_header.tx_type)::text = 'RC'::text) OR (((tx_header.tx_type)::text = 'RS'::text) AND (((tx_header.ref_number)::character varying)::text ~~ 'RC%'::text)))
  ORDER BY department.department_name, class.class_name, category.category_name, brand.brand_description, inventory.model, inventory.color, inventory.size, tx_header.date_of_entry;


--
-- Name: paste_errors; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.paste_errors (
    field0 text
);


--
-- Name: pay_per; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pay_per (
    code character varying(1) NOT NULL,
    name character varying(10) NOT NULL
);


--
-- Name: pay_period; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pay_period (
    code character varying(1) NOT NULL,
    name character varying(10) NOT NULL
);


--
-- Name: payment_methods; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.payment_methods (
    payment_code character varying(1) NOT NULL,
    payment_name_short character varying(3) NOT NULL,
    payment_name_long character varying(20) NOT NULL,
    exchange_rate double precision DEFAULT 0 NOT NULL,
    revised_date timestamp without time zone,
    today_amt_opening numeric(19,4) DEFAULT 0,
    today_amt_closing numeric(19,4) DEFAULT 0,
    today_amt_sold numeric(19,4) DEFAULT 0,
    today_number_of_sold integer DEFAULT 0,
    today_amt_refund numeric(19,4) DEFAULT 0,
    today_number_of_refund integer DEFAULT 0,
    today_amt_changed numeric(19,4) DEFAULT 0,
    today_number_of_change integer DEFAULT 0,
    today_amt_paid_out numeric(19,4) DEFAULT 0,
    today_number_of_paid_out integer DEFAULT 0,
    today_amt_bank_in numeric(19,4) DEFAULT 0,
    today_number_of_bank_in integer DEFAULT 0,
    alert_level numeric(19,4) DEFAULT 0
);


--
-- Name: payment_summary; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.payment_summary (
    payment_code character varying(1) NOT NULL,
    date timestamp without time zone NOT NULL,
    exchange_rate integer DEFAULT 0 NOT NULL,
    amt_opening numeric(19,4) DEFAULT 0,
    amt_closing numeric(19,4) DEFAULT 0,
    amt_sold numeric(19,4) DEFAULT 0,
    number_of_sold integer DEFAULT 0,
    amt_refund numeric(19,4) DEFAULT 0,
    number_of_refund integer DEFAULT 0,
    amt_changed numeric(19,4) DEFAULT 0,
    number_of_change integer DEFAULT 0,
    amt_paid_out numeric(19,4) DEFAULT 0,
    number_of_paid_out integer DEFAULT 0,
    amt_bank_in numeric(19,4) DEFAULT 0,
    number_of_bank_in integer DEFAULT 0
);


--
-- Name: pref_tx_number; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pref_tx_number (
    tx_prefix character varying(2) NOT NULL,
    tx_next_number integer DEFAULT 0 NOT NULL,
    value character varying(3),
    description character varying(30) NOT NULL,
    remarks character varying(30)
);


--
-- Name: preference; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.preference (
    serial_number character varying(10) NOT NULL,
    number_of_user integer DEFAULT 0 NOT NULL,
    platform character varying(20) NOT NULL,
    product_name character varying(128) NOT NULL,
    date_of_installation timestamp without time zone,
    user_name character varying(40) NOT NULL,
    user_address character varying(128),
    user_city integer DEFAULT 0,
    user_province character varying(2),
    user_postal_code character varying(8),
    user_country character varying(20),
    user_phone character varying(15),
    user_fax character varying(15),
    user_contact_person character varying(30),
    owner_name character varying(40) NOT NULL,
    owner_address character varying(128),
    owner_city integer DEFAULT 0,
    owner_province character varying(2),
    owner_postal_code character varying(8),
    owner_country character varying(20),
    owner_phone character varying(15),
    owner_fax character varying(15),
    owner_contact_person character varying(30),
    branch_number character varying(4) NOT NULL,
    country_code character varying(2),
    pst_number character varying(10) NOT NULL,
    gst_number character varying(10) NOT NULL,
    tax_a_rate double precision DEFAULT 0,
    tax_b_rate double precision DEFAULT 0,
    fiscal_period timestamp without time zone,
    current_month timestamp without time zone,
    next_invt_control_number integer DEFAULT 0 NOT NULL,
    next_invt_sku integer DEFAULT 0 NOT NULL,
    next_invoice_number integer DEFAULT 0 NOT NULL,
    next_sales_order_number integer DEFAULT 0 NOT NULL
);


--
-- Name: province_query; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.province_query AS
 SELECT province_name,
    province_code
   FROM public.province;


--
-- Name: qry_city_full_list; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.qry_city_full_list AS
 SELECT DISTINCT city.code,
    city.city_name,
    city.city_phone_code,
    city.province_code,
    province.province_name,
    city.country_code,
    country.country_name,
    country.country_phone_code
   FROM (public.province
     JOIN (public.country
     JOIN public.city ON (((country.country_code)::text = (city.country_code)::text))) ON (((province.province_code)::text = (city.province_code)::text)))
  ORDER BY city.city_name, province.province_name, country.country_name;


--
-- Name: qry_customer_email_list; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.qry_customer_email_list AS
 SELECT first_name,
    last_name,
    full_name,
    email
   FROM public.customer
  WHERE (email IS NOT NULL);


--
-- Name: qry_doctor; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.qry_doctor AS
 SELECT DISTINCT id,
    doctor_name
   FROM public.doctor
  ORDER BY doctor_name;


--
-- Name: qry_invt_st_details; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.qry_invt_st_details AS
 SELECT DISTINCT inventory_query.department_name,
    inventory_query.class_name,
    inventory_query.category_name,
    inventory_query.supplier_name,
    inventory_query.brand_description,
    inventory_query.model,
    inventory_query.color,
    inventory_query.size,
    inventory_query.temple,
    inventory_query.bridge,
    inventory_query.sphere,
    inventory_query.cylinder,
    inventory_query.base_curve,
    invt_st_details.id,
    invt_st_details.header_id,
    invt_st_details.computer_qty,
    invt_st_details.physical_qty,
    invt_st_details.diff_qty,
    inventory_query.average_cost,
    inventory_query.least_selling_price,
    invt_st_details.sku
   FROM (public.invt_st_details
     LEFT JOIN public.inventory_query ON (((invt_st_details.sku)::text = (inventory_query.sku)::text)));


--
-- Name: qry_orphaned_tx_details; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.qry_orphaned_tx_details AS
 SELECT tx_details.date_of_entry,
    tx_details.tx_number,
    tx_details.row_no,
    tx_details.sku,
    tx_details.tx_type,
    tx_details.qty,
    tx_details.unit_amount,
    tx_details.mark_down_amount,
    tx_details.amount
   FROM (public.tx_header
     RIGHT JOIN public.tx_details ON (((tx_header.tx_number)::text = (tx_details.tx_number)::text)))
  WHERE (tx_header.tx_number IS NULL)
  ORDER BY tx_details.date_of_entry DESC, tx_details.tx_number DESC, tx_details.row_no;


--
-- Name: qry_plu; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.qry_plu AS
 SELECT DISTINCT department_name,
    class_name,
    category_name,
    supplier_name,
    brand_description,
    material_description,
    department_code,
    class_code,
    category_code,
    supplier_code,
    brand_code,
    model,
    color,
    size,
    bridge,
    temple,
    add_code,
    material_code,
    sphere,
    cylinder,
    axis,
    base_curve,
    diameter,
    sku,
    name,
    description,
    remarks,
    abc_grading,
    inventory_type,
    inventory_status,
    kit_set_flag,
    average_cost,
    re_order_level,
    re_order_qty,
    qty_total_on_hand,
    qty_sale_order,
    qty_purchase_order,
    qty_holded,
    qty_in_transit,
    date_last_issued,
    date_last_received,
    retail_price_flag,
    whole_sale_price_flag,
    inventory_lot_flag,
    tax_method,
    least_selling_price,
    retail_price,
    retail_markdown_amt,
    retail_markdown_pct
   FROM public.inventory_query;


--
-- Name: rebuild_cost; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rebuild_cost (
    sku character varying(13) NOT NULL,
    average_cost numeric(19,4) DEFAULT 0,
    lsp numeric(19,4) DEFAULT 0
);


--
-- Name: qry_rebuild_cost; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.qry_rebuild_cost AS
 SELECT DISTINCT rebuild_cost.sku AS sku_key,
    rebuild_cost.average_cost AS avg_cost,
    rebuild_cost.lsp,
    inventory_query.department_name,
    inventory_query.class_name,
    inventory_query.category_name,
    inventory_query.supplier_name,
    inventory_query.brand_description,
    inventory_query.material_description,
    inventory_query.department_code,
    inventory_query.class_code,
    inventory_query.category_code,
    inventory_query.supplier_code,
    inventory_query.brand_code,
    inventory_query.model,
    inventory_query.color,
    inventory_query.size,
    inventory_query.bridge,
    inventory_query.temple,
    inventory_query.add_code,
    inventory_query.material_code,
    inventory_query.sphere,
    inventory_query.cylinder,
    inventory_query.axis,
    inventory_query.base_curve,
    inventory_query.diameter,
    inventory_query.sku,
    inventory_query.name,
    inventory_query.description,
    inventory_query.remarks,
    inventory_query.abc_grading,
    inventory_query.inventory_type,
    inventory_query.inventory_status,
    inventory_query.kit_set_flag,
    inventory_query.average_cost,
    inventory_query.re_order_level,
    inventory_query.re_order_qty,
    inventory_query.qty_total_on_hand,
    inventory_query.qty_sale_order,
    inventory_query.qty_purchase_order,
    inventory_query.qty_holded,
    inventory_query.qty_in_transit,
    inventory_query.date_last_issued,
    inventory_query.date_last_received,
    inventory_query.retail_price_flag,
    inventory_query.whole_sale_price_flag,
    inventory_query.inventory_lot_flag,
    inventory_query.tax_method,
    inventory_query.least_selling_price,
    inventory_query.retail_price,
    inventory_query.retail_markdown_amt,
    inventory_query.retail_markdown_pct
   FROM (public.rebuild_cost
     JOIN public.inventory_query ON (((rebuild_cost.sku)::text = (inventory_query.sku)::text)));


--
-- Name: qry_running_department; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.qry_running_department AS
 SELECT department_code,
    department_name,
    summary_flag
   FROM public.department
  WHERE ((department_code)::text <> 'SV'::text);


--
-- Name: qry_running_stock; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.qry_running_stock AS
 SELECT department_code,
    class_code,
    category_code,
    supplier_code,
    brand_code,
    model,
    color,
    size,
    bridge,
    temple,
    add_code,
    material_code,
    sphere,
    cylinder,
    axis,
    base_curve,
    diameter,
    sku,
    name,
    description,
    remarks,
    abc_grading,
    inventory_type,
    inventory_status,
    kit_set_flag,
    average_cost,
    re_order_level,
    re_order_qty,
    qty_total_on_hand,
    qty_sale_order,
    qty_purchase_order,
    qty_holded,
    qty_in_transit,
    date_last_issued,
    date_last_received,
    retail_price_flag,
    whole_sale_price_flag,
    inventory_lot_flag
   FROM public.inventory
  WHERE ((department_code)::text <> 'SV'::text);


--
-- Name: staff; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.staff (
    staff_code character varying(4) NOT NULL,
    staff_first_name character varying(20),
    staff_last_name character varying(20),
    staff_full_name character varying(40),
    staff_initial character varying(2),
    job_title character varying(4),
    job_status character varying(1),
    job_nature character varying(1),
    security_level integer DEFAULT 0 NOT NULL,
    password character varying(10),
    date_hired timestamp without time zone NOT NULL,
    date_leaved timestamp without time zone,
    sin character varying(9) NOT NULL,
    birthday timestamp without time zone,
    sex character varying(1),
    marital_status character varying(1),
    home_address character varying(128),
    home_city integer DEFAULT 0,
    home_province character varying(2),
    home_country character varying(3),
    home_postal_code character varying(8),
    home_phone character varying(10),
    home_fax character varying(10),
    salary_basic numeric(19,4) DEFAULT 0,
    salary_per character varying(1),
    salary_pay_period character varying(1),
    bank_account character varying(15),
    commission_rate integer DEFAULT 0,
    commission_bonus integer DEFAULT 0,
    commission_general integer DEFAULT 0
);


--
-- Name: tx_sale_person; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tx_sale_person (
    tx_number character varying(10) NOT NULL,
    sales_row_no double precision DEFAULT 0 NOT NULL,
    staff_code character varying(4) NOT NULL
);


--
-- Name: qry_s_order_simple; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.qry_s_order_simple AS
 SELECT DISTINCT tx_header.tx_type,
    tx_header.tx_number,
    tx_header.date_of_entry,
    tx_header.second_date,
    tx_header.ref_number,
    tx_header.customer_id,
    tx_header.particulars,
    tx_header.total_amount,
    tx_header.status,
    tx_sale_person.staff_code,
    staff.staff_full_name,
    customer.full_name,
    staff.home_phone,
    customer.home_address
   FROM (((public.tx_header
     JOIN public.tx_sale_person ON (((tx_header.tx_number)::text = (tx_sale_person.tx_number)::text)))
     JOIN public.staff ON (((tx_sale_person.staff_code)::text = (staff.staff_code)::text)))
     JOIN public.customer ON ((tx_header.customer_id = customer.id)))
  WHERE ((tx_header.tx_type)::text = 'SA'::text)
  ORDER BY tx_header.tx_number;


--
-- Name: qry_staff; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.qry_staff AS
 SELECT staff_full_name,
    staff_code,
    staff_first_name,
    staff_last_name,
    staff_initial,
    job_title,
    job_status,
    job_nature,
    security_level,
    password,
    date_hired,
    date_leaved,
    sin,
    birthday,
    sex,
    marital_status,
    home_address,
    home_city,
    home_province,
    home_country,
    home_postal_code,
    home_phone,
    home_fax,
    salary_basic,
    salary_per,
    salary_pay_period,
    bank_account,
    commission_rate,
    commission_bonus,
    commission_general
   FROM public.staff
  WHERE ((staff_code)::text < '9999'::text)
  ORDER BY staff_full_name, staff_code;


--
-- Name: qry_tx_header; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.qry_tx_header AS
 SELECT DISTINCT tx_header.control_number,
    tx_header.tx_type,
    tx_header.tx_number,
    tx_header.date_of_entry,
    tx_header.date_of_creation,
    tx_header.ref_number,
    tx_header.tracking_number,
    tx_header.customer_id,
    tx_header.supplier_code,
    tx_header.second_date,
    tx_header.particulars,
    tx_header.total_cost,
    tx_header.total_sale,
    tx_header.tax_a,
    tx_header.tax_b,
    tx_header.tax_c,
    tx_header.other_charges,
    tx_header.gross_sale,
    tx_header.sales_discount,
    tx_header.total_amount,
    tx_header.total_qty,
    tx_header.previous_paid,
    tx_header.this_paid,
    tx_header.change,
    tx_header.print_counter,
    tx_header.status,
    tx_header.payment_link,
    tx_header.sales_person_link,
    customer.full_name,
    supplier.supplier_name
   FROM ((public.tx_header
     LEFT JOIN public.customer ON ((tx_header.customer_id = customer.id)))
     LEFT JOIN public.supplier ON (((tx_header.supplier_code)::text = (supplier.supplier_code)::text)));


--
-- Name: qry_tx_payment; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.qry_tx_payment AS
 SELECT DISTINCT tx_payment.tx_number,
    tx_payment.payment_line_no,
    tx_payment.type,
    tx_payment.card_number,
    tx_payment.authorization_code,
    tx_payment.amount_tender,
    tx_payment.exchange_rate,
    tx_payment.eq_amount,
    tx_payment.total_this_pay,
    payment_methods.payment_name_long,
    tx_header.date_of_entry,
    tx_header.this_paid,
    tx_header.change,
    tx_header.payment_link
   FROM ((public.tx_payment
     LEFT JOIN public.payment_methods ON (((tx_payment.type)::text = (payment_methods.payment_code)::text)))
     LEFT JOIN public.tx_header ON (((tx_payment.tx_number)::text = (tx_header.tx_number)::text)))
  ORDER BY tx_payment.tx_number, tx_payment.payment_line_no;


--
-- Name: qry_tx_sales_person; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.qry_tx_sales_person AS
 SELECT DISTINCT tx_sale_person.tx_number,
    tx_sale_person.sales_row_no,
    tx_sale_person.staff_code,
    staff.staff_full_name
   FROM (public.staff
     RIGHT JOIN public.tx_sale_person ON (((staff.staff_code)::text = (tx_sale_person.staff_code)::text)));


--
-- Name: remarks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.remarks (
    remarks_code character varying(2) NOT NULL,
    remarks_description character varying(56),
    remarks_note text
);


--
-- Name: rpt_back_order; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.rpt_back_order AS
 SELECT "DepartmentName" AS department_name,
    "ClassName" AS class_name,
    "CategoryName" AS category_name,
    "SupplierName" AS supplier_name,
    "BrandDescription" AS brand_description,
    "Model" AS model,
    "Color" AS color,
    "Size" AS size,
    "Year" AS year,
    "Month" AS month,
    "Quarter" AS quarter,
    "UnitCost" AS unit_cost,
    "UnitAmount" AS unit_amount,
    "Amount" AS amount,
    "QtyTotalOnHand" AS qty_total_on_hand,
    "Qty" AS qty,
    "SKU" AS sku
   FROM ( SELECT DISTINCT department.department_name AS "DepartmentName",
            class.class_name AS "ClassName",
            category.category_name AS "CategoryName",
            supplier.supplier_name AS "SupplierName",
            brand.brand_description AS "BrandDescription",
            inventory.model AS "Model",
            inventory.color AS "Color",
            inventory.size AS "Size",
            EXTRACT(year FROM tx_details.date_of_entry) AS "Year",
            EXTRACT(month FROM tx_details.date_of_entry) AS "Month",
            EXTRACT(quarter FROM tx_details.date_of_entry) AS "Quarter",
            tx_details.unit_cost AS "UnitCost",
            tx_details.unit_amount AS "UnitAmount",
            tx_details.amount AS "Amount",
            inventory.qty_total_on_hand AS "QtyTotalOnHand",
            tx_details.qty AS "Qty",
            inventory.sku AS "SKU"
           FROM (public.supplier
             RIGHT JOIN (public.department
             JOIN (public.class
             JOIN (public.category
             JOIN (public.brand
             RIGHT JOIN (public.tx_header
             JOIN (public.inventory
             JOIN public.tx_details ON (((inventory.sku)::text = (tx_details.sku)::text))) ON (((tx_header.tx_number)::text = (tx_details.tx_number)::text))) ON (((brand.brand_code)::text = (inventory.brand_code)::text))) ON ((((category.category_code)::text = (inventory.category_code)::text) AND ((category.class_code)::text = (inventory.class_code)::text) AND ((category.department_code)::text = (inventory.department_code)::text)))) ON ((((class.class_code)::text = (category.class_code)::text) AND ((class.department)::text = (category.department_code)::text)))) ON (((department.department_code)::text = (class.department)::text))) ON (((supplier.supplier_code)::text = (inventory.supplier_code)::text)))
          WHERE (((tx_header.tx_type)::text = 'SA'::text) AND ((tx_header.status)::text = '1'::text))) nested
  ORDER BY "DepartmentName", "ClassName", "CategoryName", "BrandDescription", "Model", "Color", "Size", "SKU";


--
-- Name: rpt_birthday_reminder; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.rpt_birthday_reminder AS
 SELECT "DepartmentName" AS department_name,
    "ClassName" AS class_name,
    "CategoryName" AS category_name,
    "SupplierName" AS supplier_name,
    "BrandDescription" AS brand_description,
    "Model" AS model,
    "Color" AS color,
    "Size" AS size,
    "Year" AS year,
    "Month" AS month,
    "Quarter" AS quarter,
    "UnitCost" AS unit_cost,
    "UnitAmount" AS unit_amount,
    "Amount" AS amount,
    "QtyTotalOnHand" AS qty_total_on_hand,
    "Qty" AS qty,
    "SKU" AS sku
   FROM ( SELECT DISTINCT department.department_name AS "DepartmentName",
            class.class_name AS "ClassName",
            category.category_name AS "CategoryName",
            supplier.supplier_name AS "SupplierName",
            brand.brand_description AS "BrandDescription",
            inventory.model AS "Model",
            inventory.color AS "Color",
            inventory.size AS "Size",
            EXTRACT(year FROM tx_details.date_of_entry) AS "Year",
            EXTRACT(month FROM tx_details.date_of_entry) AS "Month",
            EXTRACT(quarter FROM tx_details.date_of_entry) AS "Quarter",
            tx_details.unit_cost AS "UnitCost",
            tx_details.unit_amount AS "UnitAmount",
            tx_details.amount AS "Amount",
            inventory.qty_total_on_hand AS "QtyTotalOnHand",
            tx_details.qty AS "Qty",
            inventory.sku AS "SKU"
           FROM (public.supplier
             RIGHT JOIN (public.department
             JOIN (public.class
             JOIN (public.category
             JOIN (public.brand
             RIGHT JOIN (public.tx_header
             JOIN (public.inventory
             JOIN public.tx_details ON (((inventory.sku)::text = (tx_details.sku)::text))) ON (((tx_header.tx_number)::text = (tx_details.tx_number)::text))) ON (((brand.brand_code)::text = (inventory.brand_code)::text))) ON ((((category.category_code)::text = (inventory.category_code)::text) AND ((category.class_code)::text = (inventory.class_code)::text) AND ((category.department_code)::text = (inventory.department_code)::text)))) ON ((((class.class_code)::text = (category.class_code)::text) AND ((class.department)::text = (category.department_code)::text)))) ON (((department.department_code)::text = (class.department)::text))) ON (((supplier.supplier_code)::text = (inventory.supplier_code)::text)))
          WHERE (((tx_header.tx_type)::text = 'SA'::text) AND ((tx_header.status)::text = '1'::text))) nested
  ORDER BY "DepartmentName", "ClassName", "CategoryName", "BrandDescription", "Model", "Color", "Size", "SKU";


--
-- Name: rpt_claim_receipt; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.rpt_claim_receipt AS
 SELECT DISTINCT tx_details.tx_number,
    tx_details.date_of_entry,
    class.class_name,
    tx_details.row_no,
    ((tx_details.qty)::numeric * tx_details.unit_amount) AS price,
    (((tx_details.qty)::numeric * tx_details.unit_amount) - tx_details.amount) AS discount,
    tx_details.amount AS net_paid,
    category.category_name,
    customer.last_name,
    customer.first_name,
    payment_methods.payment_name_long,
    tx_payment.payment_line_no,
    tx_payment.total_this_pay,
    tx_sale_person.staff_code
   FROM (public.department
     JOIN (public.class
     JOIN (public.category
     JOIN (((((public.tx_header
     JOIN (public.inventory
     JOIN public.tx_details ON (((inventory.sku)::text = (tx_details.sku)::text))) ON (((tx_header.tx_number)::text = (tx_details.tx_number)::text)))
     JOIN public.customer ON ((tx_header.customer_id = customer.id)))
     LEFT JOIN public.tx_payment ON (((tx_header.tx_number)::text = (tx_payment.tx_number)::text)))
     LEFT JOIN public.payment_methods ON (((tx_payment.type)::text = (payment_methods.payment_code)::text)))
     JOIN public.tx_sale_person ON (((tx_header.tx_number)::text = (tx_sale_person.tx_number)::text))) ON ((((category.department_code)::text = (inventory.department_code)::text) AND ((category.class_code)::text = (inventory.class_code)::text) AND ((category.category_code)::text = (inventory.category_code)::text)))) ON ((((class.department)::text = (category.department_code)::text) AND ((class.class_code)::text = (category.class_code)::text) AND ((class.department)::text = (category.department_code)::text) AND ((class.class_code)::text = (category.class_code)::text) AND ((class.department)::text = (category.department_code)::text) AND ((class.class_code)::text = (category.class_code)::text)))) ON (((department.department_code)::text = (class.department)::text)))
  ORDER BY tx_details.tx_number, tx_details.date_of_entry, class.class_name, tx_details.row_no;


--
-- Name: rpt_customer_home_country; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.rpt_customer_home_country AS
 SELECT DISTINCT country.country_name,
    country.country_code
   FROM (public.customer
     JOIN public.country ON (((customer.home_country)::text = (country.country_code)::text)))
  ORDER BY country.country_name;


--
-- Name: rpt_insurance_reminder; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.rpt_insurance_reminder AS
 SELECT DISTINCT customer.id,
    customer.last_name,
    customer_accounts.last_purchase_date,
    customer_medical.ins_maturity_date
   FROM ((public.customer_accounts
     JOIN public.customer ON ((customer_accounts.customer_id = customer.id)))
     JOIN public.customer_medical ON ((customer.id = customer_medical.customer_id)))
  WHERE (((customer_accounts.last_purchase_date <= customer_medical.ins_maturity_date) OR (customer_accounts.last_purchase_date IS NULL)) AND (customer_medical.ins_maturity_date <= CURRENT_TIMESTAMP) AND (customer_medical.ins_maturity_date IS NOT NULL))
  ORDER BY customer.last_name;


--
-- Name: rpt_oh_special; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.rpt_oh_special AS
 SELECT department_code,
    class_code,
    category_code,
    supplier_code,
    brand_code,
    sku,
    average_cost,
    re_order_level,
    re_order_qty,
    qty_total_on_hand,
    qty_sale_order,
    qty_purchase_order,
    qty_holded,
    qty_in_transit,
    date_last_issued,
    date_last_received,
    retail_price_flag,
    whole_sale_price_flag,
    inventory_lot_flag
   FROM public.inventory
  WHERE (((department_code)::text = 'GL'::text) AND ((class_code)::text = ANY (ARRAY[('FM'::character varying)::text, ('SS'::character varying)::text])) AND (((category_code)::character varying)::text ~~ '1%'::text) AND (qty_total_on_hand <> 0))
  ORDER BY department_code, class_code, category_code, brand_code, sku;


--
-- Name: rpt_pur_special; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.rpt_pur_special AS
 SELECT DISTINCT department.department_name,
    class.class_name,
    category.category_name,
    supplier.supplier_name,
    brand.brand_description,
    EXTRACT(year FROM tx_header.date_of_entry) AS year,
    EXTRACT(quarter FROM tx_header.date_of_entry) AS quarter,
    tx_details.qty,
    tx_details.unit_lsp,
    tx_details.unit_cost,
    tx_details.mark_down_amount,
    tx_details.amount AS purchase,
    inventory.sku,
    inventory.department_code,
    inventory.class_code,
    inventory.category_code,
    inventory.brand_code,
    inventory.model,
    inventory.sphere,
    inventory.cylinder,
    inventory.base_curve,
    inventory.diameter,
    inventory.color,
    inventory.size,
    tx_header.date_of_entry,
    tx_header.tx_type
   FROM (((((((public.tx_header
     LEFT JOIN public.tx_details ON (((tx_header.tx_number)::text = (tx_details.tx_number)::text)))
     LEFT JOIN public.inventory ON (((tx_details.sku)::text = (inventory.sku)::text)))
     LEFT JOIN public.supplier ON (((inventory.supplier_code)::text = (supplier.supplier_code)::text)))
     LEFT JOIN public.brand ON (((inventory.brand_code)::text = (brand.brand_code)::text)))
     LEFT JOIN public.category ON ((((inventory.category_code)::text = (category.category_code)::text) AND ((inventory.class_code)::text = (category.class_code)::text) AND ((inventory.department_code)::text = (category.department_code)::text))))
     LEFT JOIN public.class ON ((((category.class_code)::text = (class.class_code)::text) AND ((category.department_code)::text = (class.department)::text))))
     LEFT JOIN public.department ON (((class.department)::text = (department.department_code)::text)))
  WHERE (((inventory.department_code)::text = 'GL'::text) AND ((inventory.class_code)::text = ANY (ARRAY[('FM'::character varying)::text, ('SS'::character varying)::text])) AND (((inventory.category_code)::character varying)::text ~~ '1%'::text) AND ((tx_header.tx_type)::text = ANY (ARRAY[('SR'::character varying)::text, ('RJ'::character varying)::text])))
  ORDER BY inventory.department_code, inventory.class_code, inventory.category_code, inventory.brand_code, inventory.model, inventory.sphere, inventory.cylinder, inventory.base_curve, inventory.diameter, inventory.color, inventory.size, inventory.sku, tx_header.date_of_entry, tx_header.tx_type DESC;


--
-- Name: rpt_sales_dept_only; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.rpt_sales_dept_only AS
 SELECT department_code,
    department_name,
    summary_flag
   FROM public.department
  WHERE ((department_code)::text = ANY (ARRAY[('AC'::character varying)::text, ('GL'::character varying)::text]))
  ORDER BY department_code;


--
-- Name: rpt_wholesales_header; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.rpt_wholesales_header AS
 SELECT control_number,
    tx_type,
    tx_number,
    date_of_entry,
    date_of_creation,
    ref_number,
    tracking_number,
    customer_id,
    supplier_code,
    second_date,
    particulars,
    total_cost,
    total_sale,
    tax_a,
    tax_b,
    tax_c,
    other_charges,
    gross_sale,
    sales_discount,
    total_amount,
    total_qty,
    previous_paid,
    this_paid,
    change,
    print_counter,
    payment_link,
    sales_person_link,
    status
   FROM public.tx_header
  WHERE (((tx_type)::character varying)::text ~~ 'W%'::text);


--
-- Name: sales_order_status; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sales_order_status (
    code character varying(1) NOT NULL,
    name character varying(20) NOT NULL
);


--
-- Name: salutation; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.salutation (
    salutation character varying(6) NOT NULL
);


--
-- Name: security; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.security (
    level integer DEFAULT 0 NOT NULL,
    point_of__sale boolean,
    inventory__control boolean,
    olap boolean,
    information__centre boolean,
    coding boolean,
    report__centre boolean,
    preference boolean,
    cost boolean
);


--
-- Name: sex; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sex (
    code character varying(1) NOT NULL,
    sex character varying(10) NOT NULL
);


--
-- Name: staff_history; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.staff_history (
    staff_code character varying(4) NOT NULL,
    date timestamp without time zone NOT NULL,
    reason character varying(20),
    remarks text NOT NULL
);


--
-- Name: supplier_contact_person; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.supplier_contact_person (
    sup_code character varying(4) NOT NULL,
    first_name character varying(20) NOT NULL,
    initial character varying(2) NOT NULL,
    last_name character varying(20) NOT NULL,
    full_name character varying(40),
    salutation character varying(4),
    job_title character varying(30),
    phone_general_voice character varying(15),
    phone_general_fax character varying(15),
    phone_home character varying(12),
    phone_mobile character varying(12),
    phone_pager character varying(12),
    phone_work character varying(16)
);


--
-- Name: supplier_summary; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.supplier_summary (
    supplier_code character varying(4) NOT NULL,
    year integer DEFAULT 0 NOT NULL,
    month integer DEFAULT 0 NOT NULL,
    first_date_of_month timestamp without time zone NOT NULL,
    qty_purchased integer DEFAULT 0,
    amt_purchased numeric(19,4) DEFAULT 0,
    qty_rejected integer DEFAULT 0,
    amt_rejected numeric(19,4) DEFAULT 0
);


--
-- Name: tax_method; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tax_method (
    tax_code character varying(1) NOT NULL,
    tax_name character varying(20) NOT NULL
);


--
-- Name: tx_header_query; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.tx_header_query AS
 SELECT control_number,
    tx_type,
    tx_number,
    date_of_entry,
    date_of_creation,
    ref_number,
    tracking_number,
    customer_id,
    supplier_code,
    second_date,
    particulars,
    total_cost,
    total_sale,
    tax_a,
    tax_b,
    tax_c,
    other_charges,
    gross_sale,
    sales_discount,
    total_amount,
    total_qty,
    previous_paid,
    this_paid,
    change,
    print_counter,
    payment_link,
    sales_person_link,
    status
   FROM public.tx_header;


--
-- Name: tx_header_query1; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.tx_header_query1 AS
 SELECT control_number,
    tx_type,
    tx_number,
    date_of_entry,
    date_of_creation,
    ref_number,
    tracking_number,
    customer_id,
    supplier_code,
    second_date,
    particulars,
    total_cost,
    total_sale,
    tax_a,
    tax_b,
    tax_c,
    other_charges,
    gross_sale,
    sales_discount,
    total_amount,
    total_qty,
    previous_paid,
    this_paid,
    change,
    print_counter,
    payment_link,
    sales_person_link,
    status
   FROM public.tx_header
  WHERE ((date_of_entry > '2013-04-01 00:00:00'::timestamp without time zone) AND (tax_a <> (0)::numeric));


--
-- Name: tx_s_order_add; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tx_s_order_add (
    tx_number character varying(10) NOT NULL,
    line_number double precision DEFAULT 0 NOT NULL,
    supplier character varying(30),
    brand character varying(30),
    model character varying(30)
);


--
-- Name: tx_s_order_cont; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tx_s_order_cont (
    tx_number character varying(10) NOT NULL,
    line_number double precision DEFAULT 0 NOT NULL,
    issued_on timestamp without time zone,
    issued_by integer DEFAULT 0,
    right_sphere double precision DEFAULT 0,
    right_cylinder double precision DEFAULT 0,
    right_axis integer DEFAULT 0,
    right_k_reading_v double precision DEFAULT 0,
    right_k_reading_h double precision DEFAULT 0,
    right_palp double precision DEFAULT 0,
    right_corn double precision DEFAULT 0,
    right_pupil double precision DEFAULT 0,
    left_sphere double precision DEFAULT 0,
    left_cylinder double precision DEFAULT 0,
    left_axis integer DEFAULT 0,
    left_k_reading_v double precision DEFAULT 0,
    left_k_reading_h double precision DEFAULT 0,
    left_palp double precision DEFAULT 0,
    left_corn double precision DEFAULT 0,
    left_pupil double precision DEFAULT 0,
    history character varying(56),
    medical character varying(56),
    allergy character varying(56),
    reason character varying(56),
    evaluation character varying(56),
    test character varying(56),
    special_instruction character varying(128)
);


--
-- Name: tx_s_order_extra; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tx_s_order_extra (
    tx_number character varying(10) NOT NULL,
    redo boolean,
    warranty boolean,
    mail boolean,
    msd boolean,
    remarks integer DEFAULT 0
);


--
-- Name: tx_s_order_frame; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tx_s_order_frame (
    tx_number character varying(10) NOT NULL,
    line_number double precision DEFAULT 0 NOT NULL,
    supply boolean,
    enclosed boolean,
    follow boolean,
    lenses boolean,
    mode character varying(30),
    color character varying(8),
    eye_size character varying(6),
    bridge integer DEFAULT 0,
    temple integer DEFAULT 0,
    r1 character varying(10),
    r2 character varying(10),
    r3 character varying(10),
    a character varying(10),
    b character varying(10),
    special_instruction character varying(128)
);


--
-- Name: tx_s_order_lens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tx_s_order_lens (
    tx_number character varying(10) NOT NULL,
    line_number double precision DEFAULT 0 NOT NULL,
    issued_on timestamp without time zone,
    issued_by integer DEFAULT 0,
    right_sphere double precision DEFAULT 0,
    right_cylinder double precision DEFAULT 0,
    right_axis integer DEFAULT 0,
    right_pd_dist double precision DEFAULT 0,
    right_pd_near double precision DEFAULT 0,
    right_prism double precision DEFAULT 0,
    right_add double precision DEFAULT 0,
    right_pupil double precision DEFAULT 0,
    right_style character varying(30),
    right_seg_ht double precision DEFAULT 0,
    right_oc double precision DEFAULT 0,
    right_base double precision DEFAULT 0,
    right_vd double precision DEFAULT 0,
    left_sphere double precision DEFAULT 0,
    left_cylinder double precision DEFAULT 0,
    left_axis integer DEFAULT 0,
    left_pd_dist double precision DEFAULT 0,
    left_pd_near double precision DEFAULT 0,
    left_prism double precision DEFAULT 0,
    left_add double precision DEFAULT 0,
    left_pupil double precision DEFAULT 0,
    left_style character varying(30),
    left_seg_ht double precision DEFAULT 0,
    left_oc double precision DEFAULT 0,
    left_base double precision DEFAULT 0,
    left_vd double precision DEFAULT 0,
    type character varying(30),
    hardening character varying(30),
    material character varying(2),
    coating character varying(2),
    tint character varying(30),
    others character varying(30),
    hard_coat boolean,
    ar_coat boolean,
    uv boolean
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id integer NOT NULL,
    email character varying,
    hashed_password character varying,
    is_active boolean
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    AS integer
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
-- Name: util_check_log; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.util_check_log (
    log_number integer NOT NULL,
    date_of_log timestamp without time zone,
    parent_table character varying(30),
    parent_key character varying(30),
    remarks character varying(50)
);


--
-- Name: util_check_log__log_number_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.util_check_log__log_number_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: util_check_log__log_number_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.util_check_log__log_number_seq OWNED BY public.util_check_log.log_number;


--
-- Name: wholesale_price; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.wholesale_price (
    sku character varying(13) NOT NULL,
    suggested_retail_price numeric(19,4) DEFAULT 0,
    selling_price_grade_a numeric(19,4) DEFAULT 0,
    selling_price_grade_b numeric(19,4) DEFAULT 0,
    selling_price_grade_c numeric(19,4) DEFAULT 0
);


--
-- Name: z__default_class; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.z__default_class (
    code character varying(2) NOT NULL,
    name character varying(20) NOT NULL
);


--
-- Name: z__default_remarks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.z__default_remarks (
    id integer NOT NULL,
    "group" smallint DEFAULT 0 NOT NULL,
    remarks character varying(128)
);


--
-- Name: z_default_remarks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.z_default_remarks_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: z_default_remarks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.z_default_remarks_id_seq OWNED BY public.z__default_remarks.id;


--
-- Name: bar_code_pool id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bar_code_pool ALTER COLUMN id SET DEFAULT nextval('public.barcode_pool_id_seq'::regclass);


--
-- Name: city code; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.city ALTER COLUMN code SET DEFAULT nextval('public.city_code_seq'::regclass);


--
-- Name: customer id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customer ALTER COLUMN id SET DEFAULT nextval('public.customer_id_seq'::regclass);


--
-- Name: doctor id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.doctor ALTER COLUMN id SET DEFAULT nextval('public.doctor_id_seq'::regclass);


--
-- Name: hardening id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.hardening ALTER COLUMN id SET DEFAULT nextval('public.hardening_id_seq'::regclass);


--
-- Name: invt_st_details id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invt_st_details ALTER COLUMN id SET DEFAULT nextval('public.invt_st_details_id_seq'::regclass);


--
-- Name: invt_st_header id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invt_st_header ALTER COLUMN id SET DEFAULT nextval('public.invt_st_header_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: util_check_log log_number; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.util_check_log ALTER COLUMN log_number SET DEFAULT nextval('public.util_check_log__log_number_seq'::regclass);


--
-- Name: z__default_remarks id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.z__default_remarks ALTER COLUMN id SET DEFAULT nextval('public.z_default_remarks_id_seq'::regclass);


--
-- Name: anomaly_quarantine anomaly_quarantine_pkey; Type: CONSTRAINT; Schema: migration; Owner: -
--

ALTER TABLE ONLY migration.anomaly_quarantine
    ADD CONSTRAINT anomaly_quarantine_pkey PRIMARY KEY (id);


--
-- Name: run_log run_log_pkey; Type: CONSTRAINT; Schema: migration; Owner: -
--

ALTER TABLE ONLY migration.run_log
    ADD CONSTRAINT run_log_pkey PRIMARY KEY (id);


--
-- Name: add add_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.add
    ADD CONSTRAINT add_pkey PRIMARY KEY (add_code);


--
-- Name: bar_code_pool bar_code_pool_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bar_code_pool
    ADD CONSTRAINT bar_code_pool_pkey PRIMARY KEY (id);


--
-- Name: branch_inventory branch_inventory_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.branch_inventory
    ADD CONSTRAINT branch_inventory_pkey PRIMARY KEY (branch_code, sku);


--
-- Name: branch branch_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.branch
    ADD CONSTRAINT branch_pkey PRIMARY KEY (branch_code);


--
-- Name: branch_summary branch_summary_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.branch_summary
    ADD CONSTRAINT branch_summary_pkey PRIMARY KEY (branch_code, year, month, first_date_of_month);


--
-- Name: brand brand_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.brand
    ADD CONSTRAINT brand_pkey PRIMARY KEY (brand_code);


--
-- Name: category category_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.category
    ADD CONSTRAINT category_pkey PRIMARY KEY (department_code, class_code, category_code);


--
-- Name: category_summary category_summary_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.category_summary
    ADD CONSTRAINT category_summary_pkey PRIMARY KEY (department_code, class_code, category_code, year, month, first_date_of_month);


--
-- Name: city city__code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.city
    ADD CONSTRAINT city__code_key UNIQUE (code);


--
-- Name: city city_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.city
    ADD CONSTRAINT city_pkey PRIMARY KEY (city_name, province_code, country_code);


--
-- Name: class class_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.class
    ADD CONSTRAINT class_pkey PRIMARY KEY (department, class_code);


--
-- Name: class_summary class_summary_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.class_summary
    ADD CONSTRAINT class_summary_pkey PRIMARY KEY (department_code, class_code, year, month, first_date_of_month);


--
-- Name: costing_method costing_method__costing_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.costing_method
    ADD CONSTRAINT costing_method__costing_name_key UNIQUE (costing_name);


--
-- Name: costing_method costing_method_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.costing_method
    ADD CONSTRAINT costing_method_pkey PRIMARY KEY (costing_code);


--
-- Name: country country__country_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.country
    ADD CONSTRAINT country__country_name_key UNIQUE (country_name);


--
-- Name: country country_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.country
    ADD CONSTRAINT country_pkey PRIMARY KEY (country_code);


--
-- Name: customer_accounts customer_accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customer_accounts
    ADD CONSTRAINT customer_accounts_pkey PRIMARY KEY (customer_id);


--
-- Name: customer_medical customer_medical_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customer_medical
    ADD CONSTRAINT customer_medical_pkey PRIMARY KEY (customer_id);


--
-- Name: customer customer_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customer
    ADD CONSTRAINT customer_pkey PRIMARY KEY (id);


--
-- Name: customer_pres_contact customer_pres_contact_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customer_pres_contact
    ADD CONSTRAINT customer_pres_contact_pkey PRIMARY KEY (customer_id);


--
-- Name: customer_pres_lens customer_pres_lens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customer_pres_lens
    ADD CONSTRAINT customer_pres_lens_pkey PRIMARY KEY (customer_id);


--
-- Name: department department_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.department
    ADD CONSTRAINT department_pkey PRIMARY KEY (department_code);


--
-- Name: dept_summary dept_summary_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dept_summary
    ADD CONSTRAINT dept_summary_pkey PRIMARY KEY (department_code, year, month, first_date_of_month);


--
-- Name: doctor doctor_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.doctor
    ADD CONSTRAINT doctor_pkey PRIMARY KEY (id);


--
-- Name: footer footer_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.footer
    ADD CONSTRAINT footer_pkey PRIMARY KEY (footer_code);


--
-- Name: hardening hardening_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.hardening
    ADD CONSTRAINT hardening_pkey PRIMARY KEY (id);


--
-- Name: inventory inventory_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inventory
    ADD CONSTRAINT inventory_pkey PRIMARY KEY (sku);


--
-- Name: invt_lot_record invt_lot_record_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invt_lot_record
    ADD CONSTRAINT invt_lot_record_pkey PRIMARY KEY (sku, lot_no);


--
-- Name: invt_method invt_method__invt_method_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invt_method
    ADD CONSTRAINT invt_method__invt_method_name_key UNIQUE (invt_method_name);


--
-- Name: invt_method invt_method_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invt_method
    ADD CONSTRAINT invt_method_pkey PRIMARY KEY (invt_method_code);


--
-- Name: invt_st_details invt_st_details_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invt_st_details
    ADD CONSTRAINT invt_st_details_pkey PRIMARY KEY (header_id, sku);


--
-- Name: invt_st_header invt_st_header__name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invt_st_header
    ADD CONSTRAINT invt_st_header__name_key UNIQUE (name);


--
-- Name: invt_st_header invt_st_header_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invt_st_header
    ADD CONSTRAINT invt_st_header_pkey PRIMARY KEY (id);


--
-- Name: invt_st_import invt_st_import_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invt_st_import
    ADD CONSTRAINT invt_st_import_pkey PRIMARY KEY (header_id, sku);


--
-- Name: invt_st_status invt_st_status_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invt_st_status
    ADD CONSTRAINT invt_st_status_pkey PRIMARY KEY (code);


--
-- Name: invt_summary invt_summary_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invt_summary
    ADD CONSTRAINT invt_summary_pkey PRIMARY KEY (sku, year, month, first_date_of_month);


--
-- Name: job_nature job_nature_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.job_nature
    ADD CONSTRAINT job_nature_pkey PRIMARY KEY (code);


--
-- Name: job_status job_status_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.job_status
    ADD CONSTRAINT job_status_pkey PRIMARY KEY (code);


--
-- Name: job_title job_title__job_title_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.job_title
    ADD CONSTRAINT job_title__job_title_key UNIQUE (job_title);


--
-- Name: job_title job_title_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.job_title
    ADD CONSTRAINT job_title_pkey PRIMARY KEY (job_title_code);


--
-- Name: marital_status marital_status_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.marital_status
    ADD CONSTRAINT marital_status_pkey PRIMARY KEY (code);


--
-- Name: material material_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.material
    ADD CONSTRAINT material_pkey PRIMARY KEY (material_code);


--
-- Name: pay_per pay_per_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pay_per
    ADD CONSTRAINT pay_per_pkey PRIMARY KEY (code);


--
-- Name: pay_period pay_period_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pay_period
    ADD CONSTRAINT pay_period_pkey PRIMARY KEY (code);


--
-- Name: payment_methods payment_methods__payment_name_long_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment_methods
    ADD CONSTRAINT payment_methods__payment_name_long_key UNIQUE (payment_name_long);


--
-- Name: payment_methods payment_methods__payment_name_short_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment_methods
    ADD CONSTRAINT payment_methods__payment_name_short_key UNIQUE (payment_name_short);


--
-- Name: payment_methods payment_methods_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment_methods
    ADD CONSTRAINT payment_methods_pkey PRIMARY KEY (payment_code);


--
-- Name: payment_summary payment_summary_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment_summary
    ADD CONSTRAINT payment_summary_pkey PRIMARY KEY (payment_code, date);


--
-- Name: pref_tx_number pref_tx_number_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pref_tx_number
    ADD CONSTRAINT pref_tx_number_pkey PRIMARY KEY (tx_prefix);


--
-- Name: preference preference_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.preference
    ADD CONSTRAINT preference_pkey PRIMARY KEY (serial_number);


--
-- Name: province province_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.province
    ADD CONSTRAINT province_pkey PRIMARY KEY (province_code);


--
-- Name: rebuild_cost rebuild_cost_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rebuild_cost
    ADD CONSTRAINT rebuild_cost_pkey PRIMARY KEY (sku);


--
-- Name: remarks remarks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.remarks
    ADD CONSTRAINT remarks_pkey PRIMARY KEY (remarks_code);


--
-- Name: retail_price retail_price_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.retail_price
    ADD CONSTRAINT retail_price_pkey PRIMARY KEY (sku);


--
-- Name: sales_order_status sales_order_status_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sales_order_status
    ADD CONSTRAINT sales_order_status_pkey PRIMARY KEY (code);


--
-- Name: salutation salutation_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.salutation
    ADD CONSTRAINT salutation_pkey PRIMARY KEY (salutation);


--
-- Name: security security_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.security
    ADD CONSTRAINT security_pkey PRIMARY KEY (level);


--
-- Name: sex sex_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sex
    ADD CONSTRAINT sex_pkey PRIMARY KEY (code);


--
-- Name: staff_history staff_history_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.staff_history
    ADD CONSTRAINT staff_history_pkey PRIMARY KEY (staff_code, date);


--
-- Name: staff staff_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.staff
    ADD CONSTRAINT staff_pkey PRIMARY KEY (staff_code);


--
-- Name: supplier_contact_person supplier_contact_person_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.supplier_contact_person
    ADD CONSTRAINT supplier_contact_person_pkey PRIMARY KEY (sup_code, first_name, initial, last_name);


--
-- Name: supplier supplier_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.supplier
    ADD CONSTRAINT supplier_pkey PRIMARY KEY (supplier_code);


--
-- Name: supplier_summary supplier_summary_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.supplier_summary
    ADD CONSTRAINT supplier_summary_pkey PRIMARY KEY (supplier_code, year, month, first_date_of_month);


--
-- Name: tx_details tx_details_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tx_details
    ADD CONSTRAINT tx_details_pkey PRIMARY KEY (tx_type, tx_number, date_of_entry, row_no);


--
-- Name: tx_header tx_header_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tx_header
    ADD CONSTRAINT tx_header_pkey PRIMARY KEY (tx_number);


--
-- Name: tx_payment tx_payment_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tx_payment
    ADD CONSTRAINT tx_payment_pkey PRIMARY KEY (tx_number, payment_line_no, type);


--
-- Name: tx_s_order_add tx_s_order_add_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tx_s_order_add
    ADD CONSTRAINT tx_s_order_add_pkey PRIMARY KEY (tx_number, line_number);


--
-- Name: tx_s_order_cont tx_s_order_cont_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tx_s_order_cont
    ADD CONSTRAINT tx_s_order_cont_pkey PRIMARY KEY (tx_number, line_number);


--
-- Name: tx_s_order_extra tx_s_order_extra_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tx_s_order_extra
    ADD CONSTRAINT tx_s_order_extra_pkey PRIMARY KEY (tx_number);


--
-- Name: tx_s_order_frame tx_s_order_frame_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tx_s_order_frame
    ADD CONSTRAINT tx_s_order_frame_pkey PRIMARY KEY (tx_number, line_number);


--
-- Name: tx_s_order_lens tx_s_order_lens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tx_s_order_lens
    ADD CONSTRAINT tx_s_order_lens_pkey PRIMARY KEY (tx_number, line_number);


--
-- Name: tx_sale_person tx_sale_person_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tx_sale_person
    ADD CONSTRAINT tx_sale_person_pkey PRIMARY KEY (tx_number, sales_row_no, staff_code);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: util_check_log util_check_log_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.util_check_log
    ADD CONSTRAINT util_check_log_pkey PRIMARY KEY (log_number);


--
-- Name: wholesale_price wholesale_price_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wholesale_price
    ADD CONSTRAINT wholesale_price_pkey PRIMARY KEY (sku);


--
-- Name: z__default_class z__default_class_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.z__default_class
    ADD CONSTRAINT z__default_class_pkey PRIMARY KEY (code);


--
-- Name: z__default_remarks z__default_remarks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.z__default_remarks
    ADD CONSTRAINT z__default_remarks_pkey PRIMARY KEY (id);


--
-- Name: add__add_descriptio; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX add__add_descriptio ON public.add USING btree (add_description);


--
-- Name: bar_code_pool__id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bar_code_pool__id ON public.bar_code_pool USING btree (id);


--
-- Name: bar_code_pool__tx_number; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bar_code_pool__tx_number ON public.bar_code_pool USING btree (tx_number);


--
-- Name: branch__postal_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX branch__postal_code ON public.branch USING btree (postal_code);


--
-- Name: branch_inventory__branch_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX branch_inventory__branch_code ON public.branch_inventory USING btree (branch_code);


--
-- Name: branch_inventory__sku; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX branch_inventory__sku ON public.branch_inventory USING btree (sku);


--
-- Name: branch_summary__branch_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX branch_summary__branch_code ON public.branch_summary USING btree (branch_code);


--
-- Name: branch_summary__first_date_of_month; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX branch_summary__first_date_of_month ON public.branch_summary USING btree (first_date_of_month);


--
-- Name: branch_summary__month; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX branch_summary__month ON public.branch_summary USING btree (month);


--
-- Name: branch_summary__year; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX branch_summary__year ON public.branch_summary USING btree (year);


--
-- Name: brand__brand_description; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX brand__brand_description ON public.brand USING btree (brand_description);


--
-- Name: category__category_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX category__category_code ON public.category USING btree (category_code);


--
-- Name: category__category_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX category__category_name ON public.category USING btree (category_name);


--
-- Name: category__class_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX category__class_code ON public.category USING btree (class_code);


--
-- Name: category__department_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX category__department_code ON public.category USING btree (department_code);


--
-- Name: category_summary__category_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX category_summary__category_code ON public.category_summary USING btree (category_code);


--
-- Name: category_summary__class_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX category_summary__class_code ON public.category_summary USING btree (class_code);


--
-- Name: category_summary__department_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX category_summary__department_code ON public.category_summary USING btree (department_code);


--
-- Name: category_summary__first_date_of_month; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX category_summary__first_date_of_month ON public.category_summary USING btree (first_date_of_month);


--
-- Name: category_summary__month; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX category_summary__month ON public.category_summary USING btree (month);


--
-- Name: category_summary__year; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX category_summary__year ON public.category_summary USING btree (year);


--
-- Name: city__city_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX city__city_name ON public.city USING btree (city_name);


--
-- Name: city__city_phone_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX city__city_phone_code ON public.city USING btree (city_phone_code);


--
-- Name: city__country_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX city__country_code ON public.city USING btree (country_code);


--
-- Name: city__province_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX city__province_code ON public.city USING btree (province_code);


--
-- Name: class__class_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX class__class_code ON public.class USING btree (class_code);


--
-- Name: class__class_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX class__class_name ON public.class USING btree (class_name);


--
-- Name: class__department; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX class__department ON public.class USING btree (department);


--
-- Name: class_summary__class_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX class_summary__class_code ON public.class_summary USING btree (class_code);


--
-- Name: class_summary__first_date_of_month; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX class_summary__first_date_of_month ON public.class_summary USING btree (first_date_of_month);


--
-- Name: class_summary__month; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX class_summary__month ON public.class_summary USING btree (month);


--
-- Name: class_summary__year; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX class_summary__year ON public.class_summary USING btree (year);


--
-- Name: country__country_code1; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX country__country_code1 ON public.country USING btree (country_code);


--
-- Name: country__country_phone_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX country__country_phone_code ON public.country USING btree (country_phone_code);


--
-- Name: customer__birthday; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX customer__birthday ON public.customer USING btree (birthday);


--
-- Name: customer__biz_postal_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX customer__biz_postal_code ON public.customer USING btree (biz_postal_code);


--
-- Name: customer__country_lastname; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX customer__country_lastname ON public.customer USING btree (home_country, last_name);


--
-- Name: customer__first_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX customer__first_name ON public.customer USING btree (first_name);


--
-- Name: customer__full_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX customer__full_name ON public.customer USING btree (full_name);


--
-- Name: customer__home_country; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX customer__home_country ON public.customer USING btree (home_country);


--
-- Name: customer__home_phone; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX customer__home_phone ON public.customer USING btree (home_phone);


--
-- Name: customer__initial; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX customer__initial ON public.customer USING btree (initial);


--
-- Name: customer__last_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX customer__last_name ON public.customer USING btree (last_name);


--
-- Name: customer__vip_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX customer__vip_code ON public.customer USING btree (vip_code);


--
-- Name: customer_accounts__cust_join_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX customer_accounts__cust_join_date ON public.customer_accounts USING btree (customer_id, joint_date);


--
-- Name: customer_accounts__cust_last_purchase_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX customer_accounts__cust_last_purchase_date ON public.customer_accounts USING btree (customer_id, last_purchase_date);


--
-- Name: customer_accounts__joint_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX customer_accounts__joint_date ON public.customer_accounts USING btree (joint_date);


--
-- Name: customer_accounts__last_purchase_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX customer_accounts__last_purchase_date ON public.customer_accounts USING btree (last_purchase_date);


--
-- Name: customer_medical__cust_care_card; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX customer_medical__cust_care_card ON public.customer_medical USING btree (customer_id, care_card_no);


--
-- Name: customer_medical__cust_ins_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX customer_medical__cust_ins_date ON public.customer_medical USING btree (customer_id, ins_maturity_date);


--
-- Name: customer_post_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX customer_post_code ON public.customer USING btree (home_postal_code);


--
-- Name: department__department_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX department__department_name ON public.department USING btree (department_name);


--
-- Name: dept_summary__department_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX dept_summary__department_code ON public.dept_summary USING btree (department_code);


--
-- Name: dept_summary__first_date_of_month; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX dept_summary__first_date_of_month ON public.dept_summary USING btree (first_date_of_month);


--
-- Name: dept_summary__month; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX dept_summary__month ON public.dept_summary USING btree (month);


--
-- Name: dept_summary__year; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX dept_summary__year ON public.dept_summary USING btree (year);


--
-- Name: doctor__doctor_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX doctor__doctor_name ON public.doctor USING btree (doctor_name);


--
-- Name: doctor__id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX doctor__id ON public.doctor USING btree (id);


--
-- Name: doctor__postal_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX doctor__postal_code ON public.doctor USING btree (postal_code);


--
-- Name: hardening__id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX hardening__id ON public.hardening USING btree (id);


--
-- Name: inventory__add_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX inventory__add_code ON public.inventory USING btree (add_code);


--
-- Name: inventory__base_curve; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX inventory__base_curve ON public.inventory USING btree (base_curve);


--
-- Name: inventory__brand_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX inventory__brand_code ON public.inventory USING btree (brand_code);


--
-- Name: inventory__color; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX inventory__color ON public.inventory USING btree (color);


--
-- Name: inventory__cylinder; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX inventory__cylinder ON public.inventory USING btree (cylinder);


--
-- Name: inventory__dept_class_cat; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX inventory__dept_class_cat ON public.inventory USING btree (department_code, class_code, category_code);


--
-- Name: inventory__diameter; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX inventory__diameter ON public.inventory USING btree (diameter);


--
-- Name: inventory__material_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX inventory__material_code ON public.inventory USING btree (material_code);


--
-- Name: inventory__model; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX inventory__model ON public.inventory USING btree (model);


--
-- Name: inventory__size; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX inventory__size ON public.inventory USING btree (size);


--
-- Name: inventory__sphere; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX inventory__sphere ON public.inventory USING btree (sphere);


--
-- Name: inventory__supplier_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX inventory__supplier_code ON public.inventory USING btree (supplier_code);


--
-- Name: invt_lot_record__date_received; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX invt_lot_record__date_received ON public.invt_lot_record USING btree (date_received);


--
-- Name: invt_lot_record__lot_no; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX invt_lot_record__lot_no ON public.invt_lot_record USING btree (lot_no);


--
-- Name: invt_lot_record__sku; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX invt_lot_record__sku ON public.invt_lot_record USING btree (sku);


--
-- Name: invt_lot_record__supplier_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX invt_lot_record__supplier_code ON public.invt_lot_record USING btree (supplier_code);


--
-- Name: invt_lot_record__supplier_date_lot_no; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX invt_lot_record__supplier_date_lot_no ON public.invt_lot_record USING btree (supplier_code, date_received, lot_no);


--
-- Name: invt_st_details__header_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX invt_st_details__header_id ON public.invt_st_details USING btree (header_id);


--
-- Name: invt_st_details__id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX invt_st_details__id ON public.invt_st_details USING btree (id);


--
-- Name: invt_st_details__sku; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX invt_st_details__sku ON public.invt_st_details USING btree (sku);


--
-- Name: invt_st_header__id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX invt_st_header__id ON public.invt_st_header USING btree (id);


--
-- Name: invt_st_import__header_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX invt_st_import__header_id ON public.invt_st_import USING btree (header_id);


--
-- Name: invt_st_import__sku; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX invt_st_import__sku ON public.invt_st_import USING btree (sku);


--
-- Name: invt_st_import__status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX invt_st_import__status ON public.invt_st_import USING btree (status);


--
-- Name: invt_summary__first_date_of_month; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX invt_summary__first_date_of_month ON public.invt_summary USING btree (first_date_of_month);


--
-- Name: invt_summary__month; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX invt_summary__month ON public.invt_summary USING btree (month);


--
-- Name: invt_summary__sku; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX invt_summary__sku ON public.invt_summary USING btree (sku);


--
-- Name: invt_summary__year; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX invt_summary__year ON public.invt_summary USING btree (year);


--
-- Name: ix_users_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX ix_users_email ON public.users USING btree (email);


--
-- Name: ix_users_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_users_id ON public.users USING btree (id);


--
-- Name: material__material_description; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX material__material_description ON public.material USING btree (material_description);


--
-- Name: payment_summary__date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX payment_summary__date ON public.payment_summary USING btree (date);


--
-- Name: payment_summary__number_of_bank_in; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX payment_summary__number_of_bank_in ON public.payment_summary USING btree (number_of_bank_in);


--
-- Name: payment_summary__number_of_change; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX payment_summary__number_of_change ON public.payment_summary USING btree (number_of_change);


--
-- Name: payment_summary__number_of_paid_out; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX payment_summary__number_of_paid_out ON public.payment_summary USING btree (number_of_paid_out);


--
-- Name: payment_summary__number_of_refund; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX payment_summary__number_of_refund ON public.payment_summary USING btree (number_of_refund);


--
-- Name: payment_summary__number_of_sold; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX payment_summary__number_of_sold ON public.payment_summary USING btree (number_of_sold);


--
-- Name: payment_summary__payment_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX payment_summary__payment_code ON public.payment_summary USING btree (payment_code);


--
-- Name: preference__country_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX preference__country_code ON public.preference USING btree (country_code);


--
-- Name: preference__number_of_user; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX preference__number_of_user ON public.preference USING btree (number_of_user);


--
-- Name: preference__owner_postal_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX preference__owner_postal_code ON public.preference USING btree (owner_postal_code);


--
-- Name: preference__user_postal_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX preference__user_postal_code ON public.preference USING btree (user_postal_code);


--
-- Name: province__province_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX province__province_code ON public.province USING btree (province_code);


--
-- Name: staff__home_postal_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX staff__home_postal_code ON public.staff USING btree (home_postal_code);


--
-- Name: staff__staff_first_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX staff__staff_first_name ON public.staff USING btree (staff_first_name);


--
-- Name: staff__staff_full_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX staff__staff_full_name ON public.staff USING btree (staff_full_name);


--
-- Name: staff__staff_last_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX staff__staff_last_name ON public.staff USING btree (staff_last_name);


--
-- Name: staff_history__date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX staff_history__date ON public.staff_history USING btree (date);


--
-- Name: staff_history__staff_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX staff_history__staff_code ON public.staff_history USING btree (staff_code);


--
-- Name: supplier__sup_account_no; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX supplier__sup_account_no ON public.supplier USING btree (account_no);


--
-- Name: supplier__sup_post_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX supplier__sup_post_code ON public.supplier USING btree (post_code);


--
-- Name: supplier__supplier_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX supplier__supplier_name ON public.supplier USING btree (supplier_name);


--
-- Name: supplier_contact_person__first_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX supplier_contact_person__first_name ON public.supplier_contact_person USING btree (first_name);


--
-- Name: supplier_contact_person__full_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX supplier_contact_person__full_name ON public.supplier_contact_person USING btree (full_name);


--
-- Name: supplier_contact_person__initial; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX supplier_contact_person__initial ON public.supplier_contact_person USING btree (initial);


--
-- Name: supplier_contact_person__job_title; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX supplier_contact_person__job_title ON public.supplier_contact_person USING btree (job_title);


--
-- Name: supplier_contact_person__last_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX supplier_contact_person__last_name ON public.supplier_contact_person USING btree (last_name);


--
-- Name: supplier_contact_person__phone_general_fax; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX supplier_contact_person__phone_general_fax ON public.supplier_contact_person USING btree (phone_general_fax);


--
-- Name: supplier_contact_person__phone_general_voice; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX supplier_contact_person__phone_general_voice ON public.supplier_contact_person USING btree (phone_general_voice);


--
-- Name: supplier_contact_person__phone_home; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX supplier_contact_person__phone_home ON public.supplier_contact_person USING btree (phone_home);


--
-- Name: supplier_contact_person__phone_mobile; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX supplier_contact_person__phone_mobile ON public.supplier_contact_person USING btree (phone_mobile);


--
-- Name: supplier_contact_person__sup_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX supplier_contact_person__sup_code ON public.supplier_contact_person USING btree (sup_code);


--
-- Name: supplier_summary__month; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX supplier_summary__month ON public.supplier_summary USING btree (month);


--
-- Name: supplier_summary__supplier_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX supplier_summary__supplier_code ON public.supplier_summary USING btree (supplier_code);


--
-- Name: supplier_summary__year; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX supplier_summary__year ON public.supplier_summary USING btree (year);


--
-- Name: tax_method__tax_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tax_method__tax_code ON public.tax_method USING btree (tax_code);


--
-- Name: tx_details__control_number; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tx_details__control_number ON public.tx_details USING btree (control_number);


--
-- Name: tx_details__date_of_entry; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tx_details__date_of_entry ON public.tx_details USING btree (date_of_entry);


--
-- Name: tx_details__row_no; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tx_details__row_no ON public.tx_details USING btree (row_no);


--
-- Name: tx_details__sku; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tx_details__sku ON public.tx_details USING btree (sku);


--
-- Name: tx_details__tax_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tx_details__tax_code ON public.tx_details USING btree (tax_code);


--
-- Name: tx_details__tx_number; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tx_details__tx_number ON public.tx_details USING btree (tx_number);


--
-- Name: tx_details__tx_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tx_details__tx_type ON public.tx_details USING btree (tx_type);


--
-- Name: tx_header__control_no; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tx_header__control_no ON public.tx_header USING btree (control_number);


--
-- Name: tx_header__customer_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tx_header__customer_code ON public.tx_header USING btree (customer_id);


--
-- Name: tx_header__date_of_entry; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tx_header__date_of_entry ON public.tx_header USING btree (date_of_entry);


--
-- Name: tx_header__previous_paid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tx_header__previous_paid ON public.tx_header USING btree (previous_paid);


--
-- Name: tx_header__reference_no; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tx_header__reference_no ON public.tx_header USING btree (ref_number);


--
-- Name: tx_header__status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tx_header__status ON public.tx_header USING btree (status);


--
-- Name: tx_header__supplier_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tx_header__supplier_code ON public.tx_header USING btree (supplier_code);


--
-- Name: tx_header__this_paid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tx_header__this_paid ON public.tx_header USING btree (this_paid);


--
-- Name: tx_header__tracking_number; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tx_header__tracking_number ON public.tx_header USING btree (tracking_number);


--
-- Name: tx_header__tx_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tx_header__tx_type ON public.tx_header USING btree (tx_type);


--
-- Name: tx_payment__authorization_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tx_payment__authorization_code ON public.tx_payment USING btree (authorization_code);


--
-- Name: tx_payment__payment_seq#; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "tx_payment__payment_seq#" ON public.tx_payment USING btree (payment_line_no);


--
-- Name: tx_payment__tx_number; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tx_payment__tx_number ON public.tx_payment USING btree (tx_number);


--
-- Name: tx_payment__type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tx_payment__type ON public.tx_payment USING btree (type);


--
-- Name: tx_s_order_add__line_number; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tx_s_order_add__line_number ON public.tx_s_order_add USING btree (line_number);


--
-- Name: tx_s_order_cont__line_number; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tx_s_order_cont__line_number ON public.tx_s_order_cont USING btree (line_number);


--
-- Name: tx_s_order_cont__tx_number; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tx_s_order_cont__tx_number ON public.tx_s_order_cont USING btree (tx_number);


--
-- Name: tx_s_order_frame__line_number; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tx_s_order_frame__line_number ON public.tx_s_order_frame USING btree (line_number);


--
-- Name: tx_s_order_lens__row_no; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tx_s_order_lens__row_no ON public.tx_s_order_lens USING btree (line_number);


--
-- Name: tx_s_order_lens__tx_number; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tx_s_order_lens__tx_number ON public.tx_s_order_lens USING btree (tx_number);


--
-- Name: tx_sale_person__sales_seq#; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "tx_sale_person__sales_seq#" ON public.tx_sale_person USING btree (sales_row_no);


--
-- Name: tx_sale_person__staff_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tx_sale_person__staff_code ON public.tx_sale_person USING btree (staff_code);


--
-- Name: tx_sale_person__tx_number; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tx_sale_person__tx_number ON public.tx_sale_person USING btree (tx_number);


--
-- Name: util_check_log__parent_key; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX util_check_log__parent_key ON public.util_check_log USING btree (parent_key);


--
-- PostgreSQL database dump complete
--

\unrestrict BpMoA39so3cOdLKF6mtY4ufjVVsEIe9GcfSH726kaab2BdBjghHElr8lqf58vhJ

