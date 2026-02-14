import { useRouter } from 'next/router'
import { useEffect, useState } from 'react'
import { useFirebase } from '../../src/firebase'

export default function Workspace(){
  const router = useRouter()
  const { id } = router.query
  const { streamProjectMessages, sendMessage } = useFirebase()
  const [msgs, setMsgs] = useState([])
  const [text, setText] = useState('')

  useEffect(()=>{
    if(!id) return
    const unsub = streamProjectMessages(id, (list)=> setMsgs(list))
    return () => unsub && unsub()
  },[id])

  const send = async () => {
    if(!text) return
    await sendMessage(id, text)
    setText('')
  }

  return (
    <div className="container">
      <h2>Project Workspace</h2>
      <div className="chat">
        {msgs.map(m=> <div key={m.id} className="msg"><b>{m.sender}</b>: {m.text}</div>)}
      </div>
      <div style={{display:'flex',gap:8}}>
        <input value={text} onChange={e=>setText(e.target.value)} placeholder="Message" />
        <button onClick={send}>Send</button>
      </div>
    </div>
  )
}
