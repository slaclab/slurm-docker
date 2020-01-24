
function slurm_job_submit(job_desc, part_list, submit_uid)

  if job_desc.account == nil then
    slurm.log_user("You have to specify account using --account. Usage of default accounts is forbidden.")
    return slurm.ESLURM_INVALID_ACCOUNT
  end

  local getent_answer, username, rc
  f = io.popen("getent passwd " .. submit_uid)
  getent_answer = f:read()
  f:close()
  if not getent_answer then
    slurm.log_error("failed to lookup uid " .. submit_uid)
    return slurm.FAILURE
  end
  username = string.match(getent_answer, "^(%w+):")
  f = io.popen("sacctmgr show -n user " .. username)
  if not f:read() then
    rc = os.execute("sacctmgr create -i user " .. username ..
                      " Partition=shared" ..
                      " DefaultAccount=shared Account=shared" ..
                      " DefaultQoS=scavenger QoS=scavenger"  )
    if rc ~= 0 then
      slurm.log_error("could not add user " .. username)
      return slurm.FAILURE
    end
    slurm.log_info("added user " .. username)
  end

  return slurm.SUCCESS

end

function slurm_job_modify(job_desc, job_rec, part_list, modify_uid)

   return slurm.SUCCESS

end


