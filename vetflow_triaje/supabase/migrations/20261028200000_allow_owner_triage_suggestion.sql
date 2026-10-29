create or replace function public.protect_visit_updates()
returns trigger
language plpgsql
set search_path = ''
as $$
declare
  old_level integer;
  new_level integer;
begin
  if coalesce(auth.role(), '') <> 'service_role' then
    if new.pet_id is distinct from old.pet_id
      or new.owner_id is distinct from old.owner_id
      or new.company_id is distinct from old.company_id then
      raise exception 'Visit ownership and clinic cannot be changed by the client';
    end if;

    if auth.uid() = old.owner_id then
      if new.status is distinct from old.status
        or new.assigned_room is distinct from old.assigned_room
        or new.assigned_veterinarian is distinct from old.assigned_veterinarian
        or new.position is distinct from old.position then
        raise exception 'Only clinic staff can update visit status or queue fields';
      end if;

      if new.triage->>'confirmed' is distinct from old.triage->>'confirmed' then
        raise exception 'Only clinic staff can confirm triage';
      end if;

      old_level := case old.triage->>'suggested'
        when 'consulta' then 1
        when 'urgencia' then 2
        when 'emergencia' then 3
        else 0
      end;
      new_level := case new.triage->>'suggested'
        when 'consulta' then 1
        when 'urgencia' then 2
        when 'emergencia' then 3
        else 0
      end;
      if new_level < old_level then
        raise exception 'Suggested triage level cannot be lowered';
      end if;
    end if;

    if public.user_is_personal_for_company(old.company_id) then
      old_level := case old.triage->>'suggested'
        when 'consulta' then 1
        when 'urgencia' then 2
        when 'emergencia' then 3
        else 0
      end;
      new_level := case new.triage->>'suggested'
        when 'consulta' then 1
        when 'urgencia' then 2
        when 'emergencia' then 3
        else 0
      end;
      if new_level < old_level then
        raise exception 'Suggested triage level cannot be lowered';
      end if;
    end if;
  end if;

  return new;
end;
$$;
