PGDMP      '                 }            maturity_classifier    16.2    16.2 >    *           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false            +           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false            ,           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false            -           1262    17231    maturity_classifier    DATABASE     �   CREATE DATABASE maturity_classifier WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'Russian_Russia.1251';
 #   DROP DATABASE maturity_classifier;
                postgres    false                        2615    2200    public    SCHEMA        CREATE SCHEMA public;
    DROP SCHEMA public;
                pg_database_owner    false            .           0    0    SCHEMA public    COMMENT     6   COMMENT ON SCHEMA public IS 'standard public schema';
                   pg_database_owner    false    4            �            1255    18391 (   add_user_configuration(integer, integer)    FUNCTION     �   CREATE FUNCTION public.add_user_configuration(p_user_id integer, p_model_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO user_configurations (user_id, model_id)
    VALUES (p_user_id, p_model_id);
END;
$$;
 T   DROP FUNCTION public.add_user_configuration(p_user_id integer, p_model_id integer);
       public          postgres    false    4            �            1255    18395    analyze_results(integer)    FUNCTION     �  CREATE FUNCTION public.analyze_results(p_config_id integer) RETURNS TABLE(dimension_name character varying, average_score numeric)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT d.dimension_name, AVG(cr.score) AS average_score
    FROM checklist_results cr
    JOIN sub_dimensions sd ON cr.sub_dimension_id = sd.sub_dimension_id
    JOIN dimensions d ON sd.dimension_id = d.dimension_id
    WHERE cr.config_id = p_config_id
    GROUP BY d.dimension_name;
END;
$$;
 ;   DROP FUNCTION public.analyze_results(p_config_id integer);
       public          postgres    false    4            �            1255    18393    generate_checklist(integer)    FUNCTION       CREATE FUNCTION public.generate_checklist(p_model_id integer) RETURNS TABLE(dimension_name character varying, sub_dimension_name character varying, criteria_text text, level integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT d.dimension_name, sd.sub_dimension_name, c.criteria_text, c.level
    FROM dimensions d
    JOIN sub_dimensions sd ON d.dimension_id = sd.dimension_id
    JOIN criteria c ON sd.sub_dimension_id = c.sub_dimension_id
    WHERE d.model_id = p_model_id;
END;
$$;
 =   DROP FUNCTION public.generate_checklist(p_model_id integer);
       public          postgres    false    4            �            1255    18390    get_criteria_by_model(integer)    FUNCTION     �  CREATE FUNCTION public.get_criteria_by_model(p_model_id integer) RETURNS TABLE(dimension_name character varying, sub_dimension_name character varying, criteria_text text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT d.dimension_name, sd.sub_dimension_name, c.criteria_text
    FROM dimensions d
    JOIN sub_dimensions sd ON d.dimension_id = sd.dimension_id
    JOIN criteria c ON sd.sub_dimension_id = c.sub_dimension_id
    WHERE d.model_id = p_model_id;
END;
$$;
 @   DROP FUNCTION public.get_criteria_by_model(p_model_id integer);
       public          postgres    false    4            �            1255    18392     get_dimensions_by_model(integer)    FUNCTION     U  CREATE FUNCTION public.get_dimensions_by_model(p_model_id integer) RETURNS TABLE(dimension_id integer, dimension_name character varying, description text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT d.dimension_id, d.dimension_name, d.description
    FROM dimensions d
    WHERE d.model_id = p_model_id;
END;
$$;
 B   DROP FUNCTION public.get_dimensions_by_model(p_model_id integer);
       public          postgres    false    4            �            1255    18389    get_models()    FUNCTION     �   CREATE FUNCTION public.get_models() RETURNS TABLE(model_id integer, model_name character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT m.model_id, m.model_name
    FROM models m;
END;
$$;
 #   DROP FUNCTION public.get_models();
       public          postgres    false    4            �            1255    18396    get_recommendations(integer)    FUNCTION     O  CREATE FUNCTION public.get_recommendations(p_config_id integer) RETURNS TABLE(dimension_name character varying, sub_dimension_name character varying, criteria_text text, recommendations text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT 
        d.dimension_name,
        sd.sub_dimension_name,
        c.criteria_text,
        CASE
            WHEN c.recommendations::jsonb ? cr.score::TEXT THEN c.recommendations::jsonb ->> cr.score::TEXT
            ELSE 'Рекомендация отсутствует'
        END AS recommendations
    FROM checklist_results cr
    JOIN sub_dimensions sd ON cr.sub_dimension_id = sd.sub_dimension_id
    JOIN dimensions d ON sd.dimension_id = d.dimension_id
    JOIN criteria c ON c.sub_dimension_id = cr.sub_dimension_id
    WHERE cr.config_id = p_config_id;
END;
$$;
 ?   DROP FUNCTION public.get_recommendations(p_config_id integer);
       public          postgres    false    4            �            1255    18394 6   save_checklist_result(integer, integer, integer, text)    FUNCTION     T  CREATE FUNCTION public.save_checklist_result(p_config_id integer, p_sub_dimension_id integer, p_score integer, p_comments text) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO checklist_results (config_id, sub_dimension_id, score, comments)
    VALUES (p_config_id, p_sub_dimension_id, p_score, p_comments);
END;
$$;
    DROP FUNCTION public.save_checklist_result(p_config_id integer, p_sub_dimension_id integer, p_score integer, p_comments text);
       public          postgres    false    4            �            1259    18370    checklist_results    TABLE     �   CREATE TABLE public.checklist_results (
    result_id integer NOT NULL,
    config_id integer,
    sub_dimension_id integer,
    score integer,
    comments text,
    CONSTRAINT checklist_results_score_check CHECK (((score >= 1) AND (score <= 5)))
);
 %   DROP TABLE public.checklist_results;
       public         heap    postgres    false    4            �            1259    18369    checklist_results_result_id_seq    SEQUENCE     �   CREATE SEQUENCE public.checklist_results_result_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 6   DROP SEQUENCE public.checklist_results_result_id_seq;
       public          postgres    false    4    226            /           0    0    checklist_results_result_id_seq    SEQUENCE OWNED BY     c   ALTER SEQUENCE public.checklist_results_result_id_seq OWNED BY public.checklist_results.result_id;
          public          postgres    false    225            �            1259    18342    criteria    TABLE     �   CREATE TABLE public.criteria (
    criteria_id integer NOT NULL,
    sub_dimension_id integer,
    criteria_text text NOT NULL,
    level integer,
    recommendations text,
    CONSTRAINT criteria_level_check CHECK (((level >= 1) AND (level <= 5)))
);
    DROP TABLE public.criteria;
       public         heap    postgres    false    4            �            1259    18341    criteria_criteria_id_seq    SEQUENCE     �   CREATE SEQUENCE public.criteria_criteria_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 /   DROP SEQUENCE public.criteria_criteria_id_seq;
       public          postgres    false    222    4            0           0    0    criteria_criteria_id_seq    SEQUENCE OWNED BY     U   ALTER SEQUENCE public.criteria_criteria_id_seq OWNED BY public.criteria.criteria_id;
          public          postgres    false    221            �            1259    18314 
   dimensions    TABLE     �   CREATE TABLE public.dimensions (
    dimension_id integer NOT NULL,
    model_id integer,
    dimension_name character varying(255) NOT NULL,
    description text
);
    DROP TABLE public.dimensions;
       public         heap    postgres    false    4            �            1259    18313    dimensions_dimension_id_seq    SEQUENCE     �   CREATE SEQUENCE public.dimensions_dimension_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 2   DROP SEQUENCE public.dimensions_dimension_id_seq;
       public          postgres    false    218    4            1           0    0    dimensions_dimension_id_seq    SEQUENCE OWNED BY     [   ALTER SEQUENCE public.dimensions_dimension_id_seq OWNED BY public.dimensions.dimension_id;
          public          postgres    false    217            �            1259    18304    models    TABLE     �   CREATE TABLE public.models (
    model_id integer NOT NULL,
    model_name character varying(255) NOT NULL,
    description text,
    created_at timestamp without time zone DEFAULT now()
);
    DROP TABLE public.models;
       public         heap    postgres    false    4            �            1259    18303    models_model_id_seq    SEQUENCE     �   CREATE SEQUENCE public.models_model_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 *   DROP SEQUENCE public.models_model_id_seq;
       public          postgres    false    4    216            2           0    0    models_model_id_seq    SEQUENCE OWNED BY     K   ALTER SEQUENCE public.models_model_id_seq OWNED BY public.models.model_id;
          public          postgres    false    215            �            1259    18328    sub_dimensions    TABLE     �   CREATE TABLE public.sub_dimensions (
    sub_dimension_id integer NOT NULL,
    dimension_id integer,
    sub_dimension_name character varying(255) NOT NULL,
    description text
);
 "   DROP TABLE public.sub_dimensions;
       public         heap    postgres    false    4            �            1259    18327 #   sub_dimensions_sub_dimension_id_seq    SEQUENCE     �   CREATE SEQUENCE public.sub_dimensions_sub_dimension_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 :   DROP SEQUENCE public.sub_dimensions_sub_dimension_id_seq;
       public          postgres    false    220    4            3           0    0 #   sub_dimensions_sub_dimension_id_seq    SEQUENCE OWNED BY     k   ALTER SEQUENCE public.sub_dimensions_sub_dimension_id_seq OWNED BY public.sub_dimensions.sub_dimension_id;
          public          postgres    false    219            �            1259    18357    user_configurations    TABLE     �   CREATE TABLE public.user_configurations (
    config_id integer NOT NULL,
    user_id integer,
    model_id integer,
    created_at timestamp without time zone DEFAULT now()
);
 '   DROP TABLE public.user_configurations;
       public         heap    postgres    false    4            �            1259    18356 !   user_configurations_config_id_seq    SEQUENCE     �   CREATE SEQUENCE public.user_configurations_config_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 8   DROP SEQUENCE public.user_configurations_config_id_seq;
       public          postgres    false    4    224            4           0    0 !   user_configurations_config_id_seq    SEQUENCE OWNED BY     g   ALTER SEQUENCE public.user_configurations_config_id_seq OWNED BY public.user_configurations.config_id;
          public          postgres    false    223            x           2604    18373    checklist_results result_id    DEFAULT     �   ALTER TABLE ONLY public.checklist_results ALTER COLUMN result_id SET DEFAULT nextval('public.checklist_results_result_id_seq'::regclass);
 J   ALTER TABLE public.checklist_results ALTER COLUMN result_id DROP DEFAULT;
       public          postgres    false    226    225    226            u           2604    18345    criteria criteria_id    DEFAULT     |   ALTER TABLE ONLY public.criteria ALTER COLUMN criteria_id SET DEFAULT nextval('public.criteria_criteria_id_seq'::regclass);
 C   ALTER TABLE public.criteria ALTER COLUMN criteria_id DROP DEFAULT;
       public          postgres    false    222    221    222            s           2604    18317    dimensions dimension_id    DEFAULT     �   ALTER TABLE ONLY public.dimensions ALTER COLUMN dimension_id SET DEFAULT nextval('public.dimensions_dimension_id_seq'::regclass);
 F   ALTER TABLE public.dimensions ALTER COLUMN dimension_id DROP DEFAULT;
       public          postgres    false    218    217    218            q           2604    18307    models model_id    DEFAULT     r   ALTER TABLE ONLY public.models ALTER COLUMN model_id SET DEFAULT nextval('public.models_model_id_seq'::regclass);
 >   ALTER TABLE public.models ALTER COLUMN model_id DROP DEFAULT;
       public          postgres    false    215    216    216            t           2604    18331    sub_dimensions sub_dimension_id    DEFAULT     �   ALTER TABLE ONLY public.sub_dimensions ALTER COLUMN sub_dimension_id SET DEFAULT nextval('public.sub_dimensions_sub_dimension_id_seq'::regclass);
 N   ALTER TABLE public.sub_dimensions ALTER COLUMN sub_dimension_id DROP DEFAULT;
       public          postgres    false    220    219    220            v           2604    18360    user_configurations config_id    DEFAULT     �   ALTER TABLE ONLY public.user_configurations ALTER COLUMN config_id SET DEFAULT nextval('public.user_configurations_config_id_seq'::regclass);
 L   ALTER TABLE public.user_configurations ALTER COLUMN config_id DROP DEFAULT;
       public          postgres    false    224    223    224            '          0    18370    checklist_results 
   TABLE DATA           d   COPY public.checklist_results (result_id, config_id, sub_dimension_id, score, comments) FROM stdin;
    public          postgres    false    226   �W       #          0    18342    criteria 
   TABLE DATA           h   COPY public.criteria (criteria_id, sub_dimension_id, criteria_text, level, recommendations) FROM stdin;
    public          postgres    false    222   �X                 0    18314 
   dimensions 
   TABLE DATA           Y   COPY public.dimensions (dimension_id, model_id, dimension_name, description) FROM stdin;
    public          postgres    false    218   <[                 0    18304    models 
   TABLE DATA           O   COPY public.models (model_id, model_name, description, created_at) FROM stdin;
    public          postgres    false    216   �[       !          0    18328    sub_dimensions 
   TABLE DATA           i   COPY public.sub_dimensions (sub_dimension_id, dimension_id, sub_dimension_name, description) FROM stdin;
    public          postgres    false    220   �\       %          0    18357    user_configurations 
   TABLE DATA           W   COPY public.user_configurations (config_id, user_id, model_id, created_at) FROM stdin;
    public          postgres    false    224   �]       5           0    0    checklist_results_result_id_seq    SEQUENCE SET     M   SELECT pg_catalog.setval('public.checklist_results_result_id_seq', 3, true);
          public          postgres    false    225            6           0    0    criteria_criteria_id_seq    SEQUENCE SET     F   SELECT pg_catalog.setval('public.criteria_criteria_id_seq', 3, true);
          public          postgres    false    221            7           0    0    dimensions_dimension_id_seq    SEQUENCE SET     I   SELECT pg_catalog.setval('public.dimensions_dimension_id_seq', 3, true);
          public          postgres    false    217            8           0    0    models_model_id_seq    SEQUENCE SET     A   SELECT pg_catalog.setval('public.models_model_id_seq', 2, true);
          public          postgres    false    215            9           0    0 #   sub_dimensions_sub_dimension_id_seq    SEQUENCE SET     Q   SELECT pg_catalog.setval('public.sub_dimensions_sub_dimension_id_seq', 3, true);
          public          postgres    false    219            :           0    0 !   user_configurations_config_id_seq    SEQUENCE SET     O   SELECT pg_catalog.setval('public.user_configurations_config_id_seq', 1, true);
          public          postgres    false    223            �           2606    18378 (   checklist_results checklist_results_pkey 
   CONSTRAINT     m   ALTER TABLE ONLY public.checklist_results
    ADD CONSTRAINT checklist_results_pkey PRIMARY KEY (result_id);
 R   ALTER TABLE ONLY public.checklist_results DROP CONSTRAINT checklist_results_pkey;
       public            postgres    false    226            �           2606    18350    criteria criteria_pkey 
   CONSTRAINT     ]   ALTER TABLE ONLY public.criteria
    ADD CONSTRAINT criteria_pkey PRIMARY KEY (criteria_id);
 @   ALTER TABLE ONLY public.criteria DROP CONSTRAINT criteria_pkey;
       public            postgres    false    222            ~           2606    18321    dimensions dimensions_pkey 
   CONSTRAINT     b   ALTER TABLE ONLY public.dimensions
    ADD CONSTRAINT dimensions_pkey PRIMARY KEY (dimension_id);
 D   ALTER TABLE ONLY public.dimensions DROP CONSTRAINT dimensions_pkey;
       public            postgres    false    218            |           2606    18312    models models_pkey 
   CONSTRAINT     V   ALTER TABLE ONLY public.models
    ADD CONSTRAINT models_pkey PRIMARY KEY (model_id);
 <   ALTER TABLE ONLY public.models DROP CONSTRAINT models_pkey;
       public            postgres    false    216            �           2606    18335 "   sub_dimensions sub_dimensions_pkey 
   CONSTRAINT     n   ALTER TABLE ONLY public.sub_dimensions
    ADD CONSTRAINT sub_dimensions_pkey PRIMARY KEY (sub_dimension_id);
 L   ALTER TABLE ONLY public.sub_dimensions DROP CONSTRAINT sub_dimensions_pkey;
       public            postgres    false    220            �           2606    18363 ,   user_configurations user_configurations_pkey 
   CONSTRAINT     q   ALTER TABLE ONLY public.user_configurations
    ADD CONSTRAINT user_configurations_pkey PRIMARY KEY (config_id);
 V   ALTER TABLE ONLY public.user_configurations DROP CONSTRAINT user_configurations_pkey;
       public            postgres    false    224            �           2606    18379 2   checklist_results checklist_results_config_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.checklist_results
    ADD CONSTRAINT checklist_results_config_id_fkey FOREIGN KEY (config_id) REFERENCES public.user_configurations(config_id) ON DELETE CASCADE;
 \   ALTER TABLE ONLY public.checklist_results DROP CONSTRAINT checklist_results_config_id_fkey;
       public          postgres    false    4740    226    224            �           2606    18384 9   checklist_results checklist_results_sub_dimension_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.checklist_results
    ADD CONSTRAINT checklist_results_sub_dimension_id_fkey FOREIGN KEY (sub_dimension_id) REFERENCES public.sub_dimensions(sub_dimension_id);
 c   ALTER TABLE ONLY public.checklist_results DROP CONSTRAINT checklist_results_sub_dimension_id_fkey;
       public          postgres    false    4736    226    220            �           2606    18351 '   criteria criteria_sub_dimension_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.criteria
    ADD CONSTRAINT criteria_sub_dimension_id_fkey FOREIGN KEY (sub_dimension_id) REFERENCES public.sub_dimensions(sub_dimension_id) ON DELETE CASCADE;
 Q   ALTER TABLE ONLY public.criteria DROP CONSTRAINT criteria_sub_dimension_id_fkey;
       public          postgres    false    222    220    4736            �           2606    18322 #   dimensions dimensions_model_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.dimensions
    ADD CONSTRAINT dimensions_model_id_fkey FOREIGN KEY (model_id) REFERENCES public.models(model_id) ON DELETE CASCADE;
 M   ALTER TABLE ONLY public.dimensions DROP CONSTRAINT dimensions_model_id_fkey;
       public          postgres    false    216    4732    218            �           2606    18336 /   sub_dimensions sub_dimensions_dimension_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sub_dimensions
    ADD CONSTRAINT sub_dimensions_dimension_id_fkey FOREIGN KEY (dimension_id) REFERENCES public.dimensions(dimension_id) ON DELETE CASCADE;
 Y   ALTER TABLE ONLY public.sub_dimensions DROP CONSTRAINT sub_dimensions_dimension_id_fkey;
       public          postgres    false    220    218    4734            �           2606    18364 5   user_configurations user_configurations_model_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.user_configurations
    ADD CONSTRAINT user_configurations_model_id_fkey FOREIGN KEY (model_id) REFERENCES public.models(model_id);
 _   ALTER TABLE ONLY public.user_configurations DROP CONSTRAINT user_configurations_model_id_fkey;
       public          postgres    false    4732    224    216            '   �   x�%���0���)2R)�0)�l���P�RV8o��(r$;ߝ/��x7Y��������(1���iB�=&���ꤑG:��9�v��O#�ͲS��4䜯Ɛ�s 6�(�d�"_ӫ�.��>ɞ�#� �m�5�?L���0J��,���b�H]b5B	�͛m�4�/g��B��      #   w  x��T�n�@=��Xq�"A�K��o�ת�I)�^ڴP�`;��/��Q߼���*�ywg�y�փ`����d�ג�ZJ�4�k�;�AC���G@)�.�p��rl�.�ϣO���������T���[T�,i�E�֒�QUͪ�����dX������ԢuɅ�
;FZ���v��gG^C��)+�NNV ���/�G�_��r�`la�ô�HP��\�L�Nb�#���YXw� uن�$�w�� �e����d�����du�[�K��LW����j��rk$'�^�ZN��<>M?oS�&1�LC�<�����Ꙧ���A���>��)�ٞ,���q����`��o�p4P���Ј07' Z-k~S���ջ�߭��Y�"��RB�.Ms�,
-0�8"N������;���"���'�_ޓ���wqr�tq���������}JQAќ������N�in3A�Y����F۾(xE�U�C��Z9� �&�\���������۵k�͈��HgM�f�����wies�B�~ D�ؔ//s���;�eAMB^�ƌ��;��F(�9d�?x)�#�S��B�����a��K�2���˷\-�����䕑{Ǐ�{��_V��m         �   x�3�4�.)J,IM��0�bۅ��^�ua���ƋM.l���|aǅ\F@�!��y�9�ʁ�.�9�.�b���\ƜF���e�Ey�yɩ�_�2��&����* u�
�� �v ��^쾰���3.,����� �_b\         �   x�3�t�L�,I�Q�M,)-�,�T��OI��0�bۅ��^�ua����b�ņ�.l�
�9[/쾰�b�Ŧ;���]�sa��@-;.��4202�50�5�P00�2��20�36���0�2�t�w��0�gȘ�=
�/���h�n��;.��M
��@��^���rƅE������� �wq�      !   �   x�5�M
�@��3���'W.����uF�(�S�g��֭x�Z)���+��ȴ"!$y�|�'<ѱ��pdU[=Ɓq|h�	2���@��AAZњ�R~��Up���D�Llcgڍ�Q]i�g�c �R��bf��[,oyzʺ�E3�Ӿj���$�hYFF���?��GL;䴧�*ᴩ��b�jR�/#`�I      %   ,   x�3�4B##S]C]#+#K+C=#K#KK�=... ~?�     