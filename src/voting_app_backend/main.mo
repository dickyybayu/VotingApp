import HashMap "mo:base/HashMap";
import Nat "mo:base/Nat";
import Text "mo:base/Text";
import Iter "mo:base/Iter";
import Principal "mo:base/Principal";
import Error "mo:base/Error";
import Hash "mo:base/Hash";
import Nat32 "mo:base/Nat32";

actor VotingApp {
    public type Candidate = {
        id : Nat;
        name : Text;
        votes : Nat;
    };

    let owner : Principal = Principal.fromActor(VotingApp);

    // Kandidat dengan ID unik
    var candidates : HashMap.HashMap<Nat, Candidate> = HashMap.HashMap<Nat, Candidate>(
        10,
        Nat.equal,
        func(n : Nat) : Hash.Hash { return Nat32.fromNat(n); }
    );

    // Voters HashMap (untuk memeriksa apakah pengguna sudah memilih)
    var voters : HashMap.HashMap<Principal, Bool> = HashMap.HashMap<Principal, Bool>(
        10,
        Principal.equal,
        Principal.hash
    );

    var nextCandidateId : Nat = 0;

    // Fungsi untuk memastikan hanya pemilik yang dapat melakukan tindakan tertentu
    public shared (msg) func onlyOwner() : async () {
        if (not Principal.equal(msg.caller, owner)) {
            throw Error.reject("Only the owner can perform this action.");
        };
    };

    // Menambahkan kandidat baru
    public shared (msg) func addCandidate(name : Text) : async Candidate {
        await onlyOwner();

        let newCandidate = {
            id = nextCandidateId;
            name = name;
            votes = 0;
        };

        candidates.put(nextCandidateId, newCandidate);
        nextCandidateId += 1;

        return newCandidate;
    };

    // Mengambil semua kandidat
    public query func getCandidates() : async [Candidate] {
        return Iter.toArray(candidates.vals());
    };

    // Memberikan suara
    public shared (msg) func castVote(candidateId : Nat) : async Text {
        if (voters.get(msg.caller) == ?true) {
            return "You have already voted!";
        };

        switch (candidates.get(candidateId)) {
            case (?candidate) {
                let updatedCandidate = { candidate with votes = candidate.votes + 1 };
                candidates.put(candidateId, updatedCandidate);
                voters.put(msg.caller, true);
                return "Vote cast successfully!";
            };
            case (_) {
                return "Candidate not found!";
            };
        };
    };

    // Mengambil jumlah suara kandidat
    public query func getVotes(candidateId : Nat) : async ?Nat {
        switch (candidates.get(candidateId)) {
            case (?candidate) return ?candidate.votes;
            case (_) return null;
        };
    };

    // Reset semua voting dan kandidat (pemilik saja)
    public shared (msg) func resetVoting() : async Text {
        await onlyOwner();

        // Reset jumlah suara kandidat
        for (candidate in candidates.vals()) {
            let resetCandidate = { candidate with votes = 0 };
            candidates.put(resetCandidate.id, resetCandidate);
        };

        // Bersihkan daftar pemilih
        voters := HashMap.HashMap<Principal, Bool>(
        10, 
        Principal.equal, 
        Principal.hash,
    );

        return "Voting has been reset.";
    };
};
