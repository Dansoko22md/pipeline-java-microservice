package tn.esprit.devops.repositories;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import tn.esprit.devops.entities.Client;
@Repository
public interface IClientRepository extends JpaRepository<Client, Long> {
}