HydraShield::Engine.routes.draw do

  jsonld_request = -> (request) { request.negotiate_mime([Mime::JSONLD, Mime::JSON]) }

  constraints jsonld_request do
    get "/",               to: "hydra#entry_point", as: :entry_point
    get "/contexts",       to: "hydra#contexts",    as: :contexts
    get "/contexts/:type", to: "hydra#context",     as: :context
    get "/vocab",          to: "hydra#vocab",       as: :vocab
  end
end
