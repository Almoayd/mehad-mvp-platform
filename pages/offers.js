import { useEffect, useState } from 'react'
import { useFirebase } from '../src/firebase'

export default function Offers(){
  const { listMyProjectsWithOffers } = useFirebase()
  const [items, setItems] = useState([])

  useEffect(()=>{
    const unsub = listMyProjectsWithOffers((data)=> setItems(data))
    return () => unsub && unsub()
  },[])

  return (
    <div className="container">
      <h2>Offers</h2>
      {items.map(p => (
        <div key={p.id} className="card">
          <h3>{p.type}</h3>
          {p.offers?.map(o => (
            <div key={o.id} style={{borderTop:'1px solid #eee',paddingTop:8}}>
              <div>Price: {o.price}</div>
              <div>{o.message}</div>
            </div>
          ))}
        </div>
      ))}
    </div>
  )
}
