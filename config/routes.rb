HydraShield::Engine.routes.draw do

  jsonld_request = -> (request) { request.negotiate_mime(Mime::JSONLD, Mime::JSON) }

  constraints jsonld_request do
    get "/",               to: "shield#entry_point", as: :entry_point
    get "/contexts",       to: "shield#contexts",    as: :contexts
    get "/contexts/:type", to: "shield#context",     as: :context
    get "/vocab",          to: "shield#vocab",       as: :vocab
  end
end
