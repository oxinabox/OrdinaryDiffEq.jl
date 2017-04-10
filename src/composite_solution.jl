type ODECompositeSolution{uType,uType2,uEltype,tType,rateType,P,A,IType} <: AbstractODESolution
  u::uType
  u_analytic::uType2
  errors::Dict{Symbol,uEltype}
  t::tType
  k::rateType
  prob::P
  alg::A
  interp::IType
  alg_choice::Vector{Int}
  dense::Bool
  tslocation::Int
  retcode::Symbol
end
(sol::ODECompositeSolution)(t,deriv::Type=Val{0};idxs=nothing) = sol.interp(t,idxs,deriv)
(sol::ODECompositeSolution)(v,t,deriv::Type=Val{0};idxs=nothing) = sol.interp(v,t,idxs,deriv)

function build_solution{uType,tType,isinplace}(
        prob::AbstractODEProblem{uType,tType,isinplace},
        alg::OrdinaryDiffEqCompositeAlgorithm,t,u;dense=false,alg_choice=[1],
        k=[],interp = (tvals) -> nothing,
        timeseries_errors=true,dense_errors=true,
        calculate_error = true, retcode = :Default, kwargs...)
  if has_analytic(prob.f)
    u_analytic = Vector{uType}(0)
    errors = Dict{Symbol,eltype(u[1])}()
    sol = ODECompositeSolution(u,u_analytic,errors,t,k,prob,alg,interp,alg_choice,dense,0,retcode)
    if calculate_error
      calculate_solution_errors!(sol;timeseries_errors=timeseries_errors,dense_errors=dense_errors)
    end
    return sol
  else
    return ODECompositeSolution(u,nothing,nothing,t,k,prob,alg,interp,alg_choice,dense,0,retcode)
  end
end
