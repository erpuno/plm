use Mix.Config

config :n2o,
  pickler: :n2o_secret,
  app: :plm,
  mq: :n2o_syn,
  port: 8043,
  ttl: 60*3,
  mqtt_services: [],
  ws_services: [],
  upload: "./priv/static",
  protocols: [:n2o_heart, :nitro_n2o, :n2o_ftp],
  routes: PLM.Routes

config :schema,
  boot:  [:erp_boot, :acc_boot, :fin_boot, :plm_boot, :pay_boot]

config :kvs,
  dba: :kvs_rocks,
  dba_st: :kvs_st,
  schema: [:kvs, :kvs_stream, :bpe_metainfo, :erp]

config :form,
  registry: [
    BPE.Pass,
    BPE.Forms.Create,
    BPE.Rows.Trace,
    BPE.Rows.Process,
    FIN.Rows.Account,
    FIN.Rows.Transaction,
    PLM.Forms.Error,
    PLM.Rows.Payment,
    PLM.Rows.Investment,
    PLM.Rows.Product
  ]
