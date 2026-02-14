import { useState } from 'react'
import { useRouter } from 'next/router'
import { useFirebase } from '../src/firebase'

export default function CreateProject(){
  const [type, setType] = useState('')
  const [location, setLocation] = useState('')
  const [minBudget, setMinBudget] = useState('')
  const [maxBudget, setMaxBudget] = useState('')
  const [description, setDescription] = useState('')
  const router = useRouter()
  const { createProject } = useFirebase()

  const submit = async (e) => {
    e.preventDefault()
    const id = await createProject({ type, location, minBudget, maxBudget, description })
    if (id) router.push('/projects')
  }

  return (
    <div className="container">
      <h2>Create Project</h2>
      <form onSubmit={submit} className="form">
        <input value={type} onChange={e=>setType(e.target.value)} placeholder="Project type" />
        <input value={location} onChange={e=>setLocation(e.target.value)} placeholder="Location" />
        <div style={{display:'flex',gap:8}}>
          <input value={minBudget} onChange={e=>setMinBudget(e.target.value)} placeholder="Min budget" />
          <input value={maxBudget} onChange={e=>setMaxBudget(e.target.value)} placeholder="Max budget" />
        </div>
        <textarea value={description} onChange={e=>setDescription(e.target.value)} placeholder="Description" />
        <button type="submit">Submit project</button>
      </form>
    </div>
  )
}
