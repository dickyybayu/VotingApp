import React, { useState, useEffect } from "react";
import { voting_app_backend } from "../../declarations/voting_app_backend"; 

function App() {
  const [candidates, setCandidates] = useState([]); 
  const [name, setName] = useState(""); // State untuk nama kandidat baru
  const [loading, setLoading] = useState(false); // State untuk loading indicator

  // Fungsi untuk fetch daftar kandidat dari backend
  const fetchCandidates = async () => {
    try {
      const result = await voting_app_backend.getCandidates(); 
      console.log("Fetched candidates:", result); 
      setCandidates(result);
    } catch (error) {
      console.error("Error fetching candidates:", error);
    }
  };

  useEffect(() => {
    fetchCandidates();
  }, []);

  const addCandidate = async () => {
    if (!name) return;
    setLoading(true);
    try {
      const newCandidate = await voting_app_backend.addCandidate(name);
      console.log("Added candidate:", newCandidate); 
      setName("");
      await fetchCandidates(); 
    } catch (error) {
      console.error("Error adding candidate:", error);
    }
    setLoading(false);
  };

  const castVote = async (id) => {
    try {
      const result = await voting_app_backend.castVote(id);
      if (result) {
        alert("Vote successful!");
        await fetchCandidates(); 
      } else {
        alert("You have already voted or candidate not found.");
      }
    } catch (error) {
      console.error("Error casting vote:", error);
    }
  };

  const resetVoting = async () => {
    setLoading(true);
    try {
      await voting_app_backend.resetVoting();
      alert("Voting has been reset.");
      await fetchCandidates();
    } catch (error) {
      console.error("Error resetting voting:", error);
    }
    setLoading(false);
  };

  return (
    <div style={{ padding: "20px", fontFamily: "Arial" }}>
      <h1>Voting App</h1>

      <div>
        <h2>Add Candidate</h2>
        <input
          type="text"
          placeholder="Candidate Name"
          value={name}
          onChange={(e) => setName(e.target.value)}
          style={{ marginRight: "10px", padding: "5px" }}
        />
        <button onClick={addCandidate} disabled={loading || !name}>
          {loading ? "Adding..." : "Add Candidate"}
        </button>
      </div>

      <div style={{ marginTop: "20px" }}>
        <h2>Candidates</h2>
        {candidates.length === 0 ? (
          <p>No candidates available.</p>
        ) : (
          <ul>
            {candidates.map((candidate, index) => (
              <li key={index} style={{ marginBottom: "10px" }}>
                <strong>{candidate.name}</strong> - Votes: {candidate.votes}
                <button
                  onClick={() => castVote(candidate.id)}
                  style={{ marginLeft: "10px" }}
                >
                  Vote
                </button>
              </li>
            ))}
          </ul>
        )}
      </div>

      <div style={{ marginTop: "20px" }}>
        <h2>Admin Actions</h2>
        <button onClick={resetVoting} disabled={loading}>
          {loading ? "Resetting..." : "Reset Voting"}
        </button>
      </div>
    </div>
  );
}

export default App;
