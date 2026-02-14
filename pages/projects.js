import Link from 'next/link'
import { useEffect, useState } from 'react'
import { useFirebase } from '../src/firebase'

export default function Projects(){
  const { listProjects } = useFirebase()
  const [projects, setProjects] = useState([])

  useEffect(()=>{
    const unsub = listProjects((items)=> setProjects(items))
    return () => unsub && unsub()
  },[])

  return (
    <div className="container">
      <h2>Projects Feed</h2>
      <div>
        {projects.map(p => (
          <div key={p.id} className="card">
            <h3>{p.type}</h3>
            <p>{p.location} • {p.minBudget} - {p.maxBudget}</p>
            <p>{p.description}</p>
            <Link href={`/workspace/${p.id}`}><a>Open workspace</a></Link>
          </div>
        ))}
      </div>
    </div>
  )
}
