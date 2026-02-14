import { useFirebase } from '../src/firebase'

export default function Admin(){
  const { listUsers, listAllProjects } = useFirebase()

  return (
    <div className="container">
      <h2>Admin</h2>
      <p>Basic moderation views are available in Firestore Console. Use this as a lightweight panel.</p>
    </div>
  )
}
