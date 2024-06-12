UPDATE ad_module SET status = 'I', isindevelopment = 'Y';

UPDATE eei_param_facturae SET url_ws_validacion = 'http://186.4.199.239:11229/ss_facturacion_electronica_1/WSRecepcion?wsdl';
UPDATE eei_param_facturae set environment = '1';
UPDATE ad_user SET password = 'cRDtpNCeBiql5KOQsKVyrA0sAiA=';
UPDATE ad_alertrecipient SET ad_user_id = NULL, sendemail = 'N';

ALTER TABLE c_bpartner DISABLE TRIGGER ALL;
UPDATE c_bpartner SET em_eei_email = 'test@test.com';
ALTER TABLE c_bpartner ENABLE TRIGGER ALL;

-- Actuaria
ALTER TABLE c_order DISABLE TRIGGER ALL;
UPDATE c_order SET EM_Eei_Email_To = 'test@test.com';
ALTER TABLE c_order ENABLE TRIGGER ALL;

ALTER TABLE c_invoice DISABLE TRIGGER ALL;
UPDATE c_invoice SET EM_Eei_Email_To = 'test@test.com';
ALTER TABLE c_invoice ENABLE TRIGGER ALL;

UPDATE scactu_config SET intiza_read_endpoint = '.', intiza_write_endpoint = '.', intiza_user = '.', intiza_pass = '.';

-- Indumot
-- UPDATE sweqx_equifax_config SET username = '.', password = '.', endpoint = '.';
UPDATE sswon_config SET date_from = '9999-12-31';
UPDATE sipcoll_config SET endpoint = '.';
UPDATE ssimag_config SET endpoint = '.';

-- Happy
ALTER TABLE sig_url_api DISABLE TRIGGER ALL;
UPDATE sig_url_api SET cedula_url_api = 'https://qahappycel.crediagil365.com/ConsultarPoliticaComercial';
UPDATE sig_url_api SET credito_url_api = 'https://qaapi.cartera365.com/api-car/v1/ingreso-credito';
UPDATE sig_url_api SET simulacion_url_api = 'https://qahappycel.crediagil365.com/Calculadora';
UPDATE sig_url_api SET velectro_url_api = 'https://qa.signed365.com/HappyBuscador/index/';
UPDATE sig_url_api SET vmanual_url_api = 'https://qaapi.cartera365.com/api-car/v1/buscador-documentos/';
UPDATE sig_url_api SET token_url_api = 'https://qaapi.cartera365.com/api-cli/v1/token';
UPDATE sig_url_api SET confirmar_credito_api = 'https://qaapi.cartera365.com/api-car/v1/confirmar-credito';
ALTER TABLE sig_url_api ENABLE TRIGGER ALL;

-- Davicom
ALTER TABLE test ALTER COLUMN id DROP DEFAULT;
DROP SEQUENCE obpos_ticketsnum;
DROP SEQUENCE obpos_ticketsnum_payment;
DROP SEQUENCE obpos_ticketsnum_refund;
